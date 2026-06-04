import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:common/imagewidget/nine_img_tool.dart';
import 'package:http/http.dart' as http;
import 'package:base/log/nine_log.dart';

import '../decryptor/nine_decrypter_new.dart';

class NineImageCacheModel {
  final String title;
  final String url;
  final int type;

  final bool needDecrypt;

  final bool compressImage;
  Size layoutSize;
  int size;
  bool isAd;
  int priority;
  int? compressCacheWidth;
  int? _lastUpdateTime;
  Uint8List? data;
  Completer? completer;
  int timeout = 300000;
  int get lastUpdateTime => _lastUpdateTime ?? 0;
  Map<int, FrameInfo> frameMap = {};

  /// 压缩宽度上限（物理像素），与下载子线程一致。
  static const int decodeMaxSideCap = 8192;

  NineImageCacheModel({
    required this.url,
    this.priority = 1,
    this.title = "",
    this.type = 0,
    Size? layoutSize,
    this.size = 0,
    this.isAd = false,
    this.needDecrypt = true,
    this.compressImage = true,
    this.compressCacheWidth,
  }) : layoutSize = layoutSize ?? Size.zero {
    completer = Completer();
    _lastUpdateTime = DateTime.now().millisecondsSinceEpoch;
  }

  void changTime() {
    _lastUpdateTime = DateTime.now().millisecondsSinceEpoch;
  }

  /// [http.get] 只发起单次请求：失败不重试。
  ///
  /// Widget 侧（例如 [NineopImage]）可叠加业务重试策略（见该组件内按需二次 [requestImageData] 等）。
  static Future<Uint8List?> fetchAndDecryptImage({
    required String url,
    bool needDecrypt = true,
  }) async {
    try {
      final Uri resolved = Uri.parse(url);
      if (!resolved.hasScheme) {
        NLog.e('http>>> Invalid URL scheme: $url');
        return null;
      }
      imgeLogD('http>>> 开始获取图片数据: $url');
      final response = await http.get(resolved).timeout(Duration(seconds: 15));

      if (response.statusCode == HttpStatus.ok &&
          response.bodyBytes.isNotEmpty) {
        if (!needDecrypt) {
          return Uint8List.fromList(response.bodyBytes);
        }
        Uint8List? data = await NineDecrypterNew.decryptImageData(
          response.bodyBytes,
          url: url,
        );
        return data;
      } else {
        imgeLogE(
          'http>>>  $url request failed, statusCode: ${response.statusCode}, $resolved',
        );
        return null;
      }
    } catch (e) {
      imgeLogE('=======>>Error loading image url:$url data: $e');
      return null;
    }
  }

  void addFrame(FrameInfo info, int index) {
    frameMap[index] = info;
  }

  FrameInfo? getFrame(int index) {
    return frameMap[index];
  }
}
