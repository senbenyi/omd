import 'dart:io';
import 'package:base/log/nine_log.dart';
import 'package:base/theme/app_theme.dart';
import 'package:common/imagewidget/cache/image_db_manage.dart';
import 'package:common/imagewidget/nine_img_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NineImageDisk {
  static String imageFilePath = "";
  static String imageDbPath = "";

  /// 磁盘缓存版本。升级后会在 [createFolderAndSaveFile] 时清理旧目录并重建路径。
  static const String imageCacheVersion = "2.0";

  static const String _prefKeyPrefix = "nine_image_disk_cache_version";

  /// 磁盘缓存文件名：仅 [url] 的 MD5。文件内容为解密后的字节；若下载管线做了压缩则为压缩后数据。
  static String fileKeyForUrl(String url) => NineImageTool.md5Str(url);

  static String _versionPrefKey(String appName) => "${_prefKeyPrefix}_$appName";

  static String _imageDirFor(String docPath, String appName, String version) =>
      "$docPath/$appName/images/$version";

  static String _dbDirFor(String docPath, String appName, String version) =>
      "$docPath/$appName/imagedn/$version";

  static Future<void> createFolderAndSaveFile() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final appName = appChannel.appName;
      final prefs = await SharedPreferences.getInstance();
      final prefKey = _versionPrefKey(appName);
      final lastVersion = prefs.getString(prefKey) ?? "";

      if (lastVersion != imageCacheVersion) {
        await _purgeCacheBeforeVersionUpgrade(
          docPath: appDocDir.path,
          appName: appName,
          lastVersion: lastVersion,
        );
        await prefs.setString(prefKey, imageCacheVersion);
      }

      imageFilePath = _imageDirFor(appDocDir.path, appName, imageCacheVersion);
      imageDbPath = _dbDirFor(appDocDir.path, appName, imageCacheVersion);

      await _ensureDirectory(Directory(imageFilePath));
      await _ensureDirectory(Directory(imageDbPath));
    } catch (e) {
      NLog.e('❌ NineImageDisk 初始化失败: $e');
    }
  }

  /// 版本变更时删除旧版及未分版本的图片 / 元数据目录。
  static Future<void> _purgeCacheBeforeVersionUpgrade({
    required String docPath,
    required String appName,
    required String lastVersion,
  }) async {
    NLog.d(
      'NineImageDisk 缓存版本升级: '
      '${lastVersion.isEmpty ? "(legacy)" : lastVersion} -> $imageCacheVersion',
    );

    if (lastVersion.isNotEmpty) {
      await _deleteDirectoryIfExists(
        _imageDirFor(docPath, appName, lastVersion),
      );
      await _deleteDirectoryIfExists(_dbDirFor(docPath, appName, lastVersion));
    }

    // 兼容历史未带版本号的路径（如 .../images、.../imagedn）
    await _deleteDirectoryIfExists("$docPath/$appName/images");
    await _deleteDirectoryIfExists("$docPath/$appName/imagedn");

    if (imageFilePath.isNotEmpty || imageDbPath.isNotEmpty) {
      await ImageDbManage.instance.clearImageCacheRecords();
    }
    await _deleteAllCachedImageFiles();
  }

  static Future<void> _ensureDirectory(Directory folder) async {
    if (!await folder.exists()) {
      await folder.create(recursive: true);
      NLog.d('📁 文件夹创建成功: ${folder.path}');
    }
  }

  static Future<void> _deleteDirectoryIfExists(String path) async {
    if (path.isEmpty) return;
    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        NLog.d('已删除图片缓存目录: $path');
      }
    } catch (e) {
      NLog.e('删除缓存目录失败 $path: $e');
    }
  }

  static Future<void> saveImage(String url, Uint8List data) async {
    try {
      String path = "$imageFilePath/${fileKeyForUrl(url)}";
      final file = File(path);
      await file.writeAsBytes(data);
    } catch (e) {
      NLog.e('❌ 保存图片出错了: $e');
    }
  }

  static Future<Uint8List> readImage(String url) async {
    try {
      String path = "$imageFilePath/${fileKeyForUrl(url)}";

      final file = File(path);
      if (!await file.exists()) {
        return Uint8List(0);
      }
      Uint8List data = await file.readAsBytes();
      return data;
    } catch (e) {
      imgeLogE('❌ 读取图片出错了: $url, $e');
      return Uint8List(0);
    }
  }

  static deleteImage(String url, {String title = ""}) {
    String path = "$imageFilePath/${fileKeyForUrl(url)}";
    try {
      final file = File(path);
      if (file.existsSync()) {
        file.delete();
        imgeLogD("删除图片成功 $title $url");
      }
    } catch (e) {
      imgeLogE("删除图片失败 $title $url");
    }
  }

  /// [imageFilePath] 目录下解密图片文件总大小，单位为 **KB**（四舍五入）。
  ///
  /// 目录未初始化或非目录时返回 0。
  static Future<int> totalCachedImageKb() async {
    if (imageFilePath.isEmpty) return 0;
    try {
      final dir = Directory(imageFilePath);
      if (!await dir.exists()) return 0;
      int sumBytes = 0;
      await for (final entity in dir.list(recursive: false)) {
        if (entity is File) {
          try {
            sumBytes += await entity.length();
          } catch (_) {}
        }
      }
      if (sumBytes == 0) return 0;
      return (sumBytes / 1024).round();
    } catch (e, s) {
      NLog.e('totalCachedImageKb 统计失败: $e\n$s');
      return 0;
    }
  }

  /// 清理当前版本磁盘缓存与 [ImageDbManage] 元数据，不修改 [imageCacheVersion]。
  static Future<void> cleanImage() async {
    try {
      if (imageFilePath.isEmpty || imageDbPath.isEmpty) {
        await createFolderAndSaveFile();
      }
      await ImageDbManage.instance.clearImageCacheRecords();
      await _deleteAllCachedImageFiles();
    } catch (e, s) {
      NLog.e('cleanImage 失败: $e\n$s');
    }
  }

  static Future<void> _deleteAllCachedImageFiles() async {
    if (imageFilePath.isEmpty) return;
    final dir = Directory(imageFilePath);
    if (!await dir.exists()) return;
    await for (final entity in dir.list(recursive: false)) {
      if (entity is! File) continue;
      try {
        await entity.delete();
      } catch (e) {
        NLog.e('删除缓存文件失败 ${entity.path}: $e');
      }
    }
  }
}
