import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:base/log/nine_log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'nine_image_cache_model.dart';
import 'nine_image_disk.dart';

enum DbExcuteStatus { success, fail }

class ImageDbManage {
  static final _instanceSingle = ImageDbManage._internal();
  factory ImageDbManage() => _instanceSingle;
  static ImageDbManage get instance => ImageDbManage();
  ImageDbManage._internal() : super();
  // int maxSize = 2 * 1024 * 1024 * 1024; //最大2G
  int maxSize = 512 * 1024 * 1024; //

  String version = "1.5";
  Database? _database;
  String tableName = "image";
  String dbName = "image";
  late String rootPath;
  late String dbPath;
  List<NineImageCacheModel> historymodels = [];
  Future<void> initDataBase() async {
    rootPath = NineImageDisk.imageDbPath;
    dbPath = "$rootPath/$dbName.db";
    await creatFile();
    try {
      _database = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) {
          String sql = '''create table $tableName 
              (id INTEGER PRIMARY KEY AUTOINCREMENT,
               url TEXT UNIQUE NOT NULL,
               title TEXT,
               updateTime INTEGER,
               size INTEGER,
               width float,
               height float)''';
          db.execute(sql);
        },
      );
      dzLog("数据库创建成功");
      bool success = await checkDbVersion();
      if (!success) {
        await initDataBase();
        return;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("db_version_$dbName", version);
    } catch (error) {
      dzLog("数据库创建失败:$error");
      await deleteDB();
      rethrow;
    }
  }

  void close() {
    _database?.close();
  }

  Future<bool> checkDbVersion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastVersion = prefs.getString("db_version_$dbName") ?? "";
    if (lastVersion != version && lastVersion.isNotEmpty) {
      await deleteDB();
      prefs.setString("db_version_$dbName", version);
      return false;
    }
    return true;
  }

  Future<void> deleteDB() async {
    _database?.close();
    _database = null;
    File file = File(dbPath);
    if (file.existsSync()) {
      file.delete();
    }
  }

  Future<void> creatFile() async {
    final folder = Directory(rootPath);
    bool isExist = await folder.exists();
    if (!isExist) {
      await folder.create();
    }
  }

  //查询指定任务
  Future<NineImageCacheModel?> query(String url) async {
    List<Map<String, dynamic>>? results = await _database?.rawQuery(
      "SELECT * FROM $tableName WHERE url = ?",
      [url],
    );
    if (results != null && results.isNotEmpty) {
      Map<String, dynamic> result = results.first;
      double width = (result["width"] ?? 0).toDouble();
      double height = (result["height"] ?? 0).toDouble();
      String title = result["title"]?.toString() ?? "";
      int size = result["size"] ?? 0;
      NineImageCacheModel model = NineImageCacheModel(
        url: result["url"]?.toString() ?? "",
        title: title,
        layoutSize: Size(width, height),
        size: size,
      );
      dzLog(
        "查询结果>>>>>>>>: ${model.title} layout:${model.layoutSize.width}x${model.layoutSize.height} url:${model.url}",
      );
      return model;
    }
    return null;
  }

  //插入数据
  Future<bool> insertOrUpdate({required NineImageCacheModel model}) async {
    try {
      NineImageCacheModel? resModel = await query(model.url);

      if (resModel != null) {
        await _updateModel(model);
      } else {
        Map<String, dynamic> map = {
          "url": model.url,
          "title": model.title,
          "width": model.layoutSize.width,
          "height": model.layoutSize.height,
          "size": model.size,
          "updateTime": model.lastUpdateTime,
        };
        await _database?.insert(tableName, map);
        // dzLog("file_db 插入Success:${model.title} url:${model.url}");
      }

      return true;
    } catch (error) {
      NLog.e("file_db 插入失败:$error");
      return false;
    }
  }

  Future<bool> _updateModel(NineImageCacheModel model) async {
    try {
      await _database?.update(
        tableName,
        {
          "updateTime": model.lastUpdateTime,
          "width": model.layoutSize.width,
          "height": model.layoutSize.height,
          "size": model.size,
          "title": model.title,
        },
        where: "url = ?",
        whereArgs: [model.url],
      );
      return true;
    } catch (error) {
      dzLog("file_db update Fail:${model.url} $error");
      return false;
    }
  }

  //更新表
  Future<bool> updateSize({
    required String url,
    required Size layoutSize,
  }) async {
    try {
      await _database?.update(
        tableName,
        {"width": layoutSize.width, "height": layoutSize.height},
        where: "url = ?",
        whereArgs: [url],
      );
      // dzLog("file_db update Success:$url");
      return true;
    } catch (error) {
      dzLog("file_db update Fail:$url $error");

      return false;
    }
  }

  Future<bool> updateTime({required String url}) async {
    int time = DateTime.now().millisecondsSinceEpoch;
    try {
      await _database?.update(
        tableName,
        {"updateTime": time},
        where: "url = ?",
        whereArgs: [url],
      );
      return true;
    } catch (error) {
      dzLog("updateTime Fail:$url $error");
      return false;
    }
  }

  //执行sql语句
  Future<bool> excute({required String sql}) async {
    try {
      await _database?.execute(sql);
      dzLog("执行Sql Success:$sql");
      return true;
    } catch (error) {
      dzLog("执行Sql失败:$sql error:$error");
      rethrow;
    }
  }

  //删除下载任务
  Future<bool> deleteDbTask({required String url}) async {
    try {
      await _database?.delete(
        tableName,
        where: "url = ?",
        whereArgs: [url],
      );
      dzLog("db删除下载任务Success:$url");
      return true;
    } catch (error) {
      dzLog("db删除下载任务失败:$url error:$error");
      return false;
    }
  }

  //删除表
  Future<void> deleteTable() async {
    try {
      await _database?.execute("DELETE FROM $tableName");
    } catch (error) {
      dzLog("db删除表失败:$error");
      rethrow;
    }
  }

  /// 清空 [tableName] 中的图片缓存元数据（保留库文件与版本迁移状态）。
  ///
  /// 若尚未 [initDataBase]，会先初始化再删除，供 [NineImageDisk.cleanImage] 与磁盘文件同步清理。
  Future<void> clearImageCacheRecords() async {
    try {
      if (NineImageDisk.imageDbPath.isEmpty) {
        return;
      }
      if (_database == null) {
        await initDataBase();
      }
      await _database?.execute("DELETE FROM $tableName");
      historymodels.clear();
      dzLog("已清空图片缓存表 $tableName");
    } catch (error) {
      dzLog("clearImageCacheRecords 失败: $error");
    }
  }

  //删除过期数据
  Future<void> deleteExpiredData() async {
    try {
      List<Map<String, dynamic>>? results = await _database?.query(
        tableName,
        columns: ['id', 'url', 'title', 'updateTime', 'size'],
        orderBy: 'updateTime DESC',
      );
      dzLog("db 总数据:${results?.length}");
      if (results != null && results.isNotEmpty) {
        int totalSize = 0;
        int? cutoffIndex;
        for (var i = 0; i < results.length; i++) {
          int size = results[i]["size"] ?? 0;
          totalSize += size;
          if (totalSize > maxSize) {
            cutoffIndex = i;
            break;
          }
        }
        if (cutoffIndex != null) {
          // 先删除所有过期项的磁盘文件，再删除 DB 记录，保持同步
          for (var i = cutoffIndex; i < results.length; i++) {
            String url = results[i]["url"] as String;
            NineImageDisk.deleteImage(url);
          }
          int saveTime = results[cutoffIndex]["updateTime"] ?? 0;
          await _database?.delete(
            tableName,
            where: "updateTime <= ?",
            whereArgs: [saveTime],
          );
        }
      }
    } catch (error) {
      dzLog("db删除过期数据失败:$error");
      rethrow;
    }
  }

  void dzLog(String message) {
    NLog.d("db=======$message");
  }
}
