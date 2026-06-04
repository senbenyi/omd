import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:base/theme/app_theme.dart';
import 'package:common/imagewidget/nine_img_tool.dart';
import 'package:flutter/services.dart';
import 'package:base/log/nine_log.dart';
import 'package:image/image.dart' as img;
import '../cache/nine_image_cache_model.dart';

class ImgIsolateKey {
  static String requesImage = "requesImage";
  static String downLoadSuccess = "downLoadSuccess";
  static String downLoadFail = "downLoadFail";
}

class NineImageDownLoader {
  // isolate & comms
  ReceivePort? _receivePort;
  SendPort? _childSendPort;
  Isolate? _isolate;
  StreamSubscription? _subscription;
  Function(String url, Uint8List data)? onSuccess;
  Function(String url, dynamic err)? onFail;
  Function(String url, double pregress)? onProgress;

  /// 初始化 isolate
  Future<void> initIsolate() async {
    try {
      Completer<void> completer = Completer<void>();
      _receivePort = ReceivePort();
      await Isolate.spawn(childEntry, _receivePort!.sendPort);
      _subscription = _receivePort?.listen((dynamic messages) async {
        try {
          // 第一次消息应该是 SendPort（子 isolate 传回给主 isolate 的端）
          if (messages is SendPort) {
            _childSendPort = messages;
            if (!completer.isCompleted) completer.complete();
            NLog.d("Isolate 创建成功，收到子端口");
            return;
          }
          if (messages is! List || messages.isEmpty) return;
          String key = messages[0];
          if (key == ImgIsolateKey.downLoadSuccess) {
            String url = messages[1];
            try {
              if (messages[2] is TransferableTypedData) {
                TransferableTypedData imageData = messages[2];
                Uint8List bytes = imageData.materialize().asUint8List();
                onSuccess?.call(url, bytes);
              } else if (messages[2] is Uint8List) {
                Uint8List bytes = messages[2];
                onSuccess?.call(url, bytes);
              }
            } catch (e) {
              onFail?.call(url, "数据异常");
            }
          } else if (key == ImgIsolateKey.downLoadFail) {
            String url = messages[1];
            dynamic error = messages.length > 2 ? messages[2] : "下载失败";
            onFail?.call(url, error);
          }
        } catch (e, s) {
          NLog.e("主 isolate 接收消息回调异常: $e\n$s");
        }
      });
      await completer.future;
      NLog.i("图片子线程创建完成");
    } catch (e) {
      NLog.e("图片子线程创建失败：  $e");
    }
  }

  /// 关闭 isolate 和流订阅
  void close() {
    _subscription?.cancel();
    _subscription = null;
    _receivePort?.close();
    _receivePort = null;
    _isolate?.kill(priority: Isolate.immediate);
    _childSendPort = null;
  }

  Future<void> startFetchImg(
    String url, {
    bool needDecrypt = true,
    bool compressImage = true,
    int compressCacheWidthPx = 0,
    String title = "",
  }) async {
    _childSendPort?.send([
      ImgIsolateKey.requesImage,
      appChannel.imageDomain,
      url,
      compressCacheWidthPx,
      needDecrypt,
      compressImage,
      title,
    ]);
  }
}

/// 子 isolate：解码后宽度大于 [maxWidthPx] 时按宽等比缩小并 JPEG；
/// 宽度严格小于 [maxWidthPx]、动画或其它不缩小分支则返回原 [bytes]。
Uint8List _processDownloadedImage(
  Uint8List bytes, {
  required int maxWidthPx,
  int jpegQualityAfterResize = 88,
  String logUrl = '',
}) {
  final int beforeBytes = bytes.length;
  final sw = Stopwatch()..start();
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      sw.stop();
      return bytes;
    }

    final mw = maxWidthPx;
    // 像素宽度已小于上限：不 resize、不转 JPEG
    if (mw > 0 && decoded.width < mw) {
      sw.stop();
      return bytes;
    }
    if (decoded.hasAnimation) {
      sw.stop();
      return bytes;
    }

    img.Image work = decoded;
    var didResize = false;
    if (mw > 0 && decoded.width > mw) {
      final scale = mw / decoded.width;
      final nw = math.max(1, mw);
      final nh = math.max(1, (decoded.height * scale).round());
      work = img.copyResize(
        decoded,
        width: nw,
        height: nh,
        interpolation: img.Interpolation.linear,
      );
      didResize = true;
    }

    final shouldEncode = didResize;
    if (!shouldEncode) {
      sw.stop();
      return bytes;
    }

    final q = jpegQualityAfterResize;
    // 调色板 / 透明度等非 JPEG 安全布局先规范为 uint8 RGB，避免花屏
    final rgb = work.convert(format: img.Format.uint8, numChannels: 3);
    final encoded = img.encodeJpg(
      rgb,
      quality: q,
      chroma: img.JpegChroma.yuv444,
    );
    final out = Uint8List.fromList(encoded);
    sw.stop();
    final costMs = sw.elapsedMicroseconds / 1000.0;
    final suffix = logUrl.isEmpty ? '' : ' url:$logUrl';
    if (!didResize && out.length >= bytes.length) {
      return bytes;
    }
    final pct =
        beforeBytes > 0
            ? (80 * out.length / beforeBytes).toStringAsFixed(1)
            : '-';
    NLog.d(
      'NineImage压缩 before:${beforeBytes ~/ 1024}kB after:${out.length ~/ 1024}kB ($pct%) '
      'resize:$didResize ${decoded.width}x${decoded.height} cost:${costMs.toStringAsFixed(2)}ms$suffix',
    );
    return out;
  } catch (_) {
    sw.stop();
    return bytes;
  }
}

bool _isGifResourceUrl(String url) {
  return url.toLowerCase().contains('.gif');
}

/// 子 isolate 的 entry（独立函数）
void childEntry(SendPort mainSendPort) {
  try {
    ReceivePort receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);
    receivePort.listen((dynamic messages) async {
      if (messages is! List || messages.isEmpty) return;
      String key = messages[0];
      if (key == ImgIsolateKey.requesImage) {
        String domain = messages.length > 1 ? messages[1] ?? "" : "";
        String url = messages.length > 2 ? messages[2] ?? "" : "";
        int compressCacheWidthPx = 0;
        bool needDecrypt = true;
        bool compressImage = true;
        String title = "";

        if (messages.length > 3 && messages[3] is int) {
          compressCacheWidthPx = messages[3] as int;
        }
        if (messages.length > 4 && messages[4] is bool) {
          needDecrypt = messages[4] as bool;
        }
        if (messages.length > 5 && messages[5] is bool) {
          compressImage = messages[5] as bool;
        }
        if (messages.length > 6 && messages[6] is String) {
          title = messages[6] as String;
        }

        compressCacheWidthPx = math.min(
          math.max(0, compressCacheWidthPx),
          NineImageCacheModel.decodeMaxSideCap,
        );
        final fetchStopwatch = Stopwatch()..start();
        Uint8List? bytes = await NineImageCacheModel.fetchAndDecryptImage(
          url: "$domain$url",
          needDecrypt: needDecrypt,
        );
        fetchStopwatch.stop();
        final fetchCostMs = fetchStopwatch.elapsedMilliseconds;

        if (bytes == null || bytes.isEmpty) {
          NLog.e("下载图片失败: $title  $domain$url 网络耗时:${fetchCostMs}ms");
        }
        if (bytes != null && bytes.isNotEmpty) {
          NLog.d(
            "图片大小:${(bytes.length / 1024).toStringAsFixed(1)}kb "
            "网络耗时:${fetchCostMs}ms $domain$url",
          );
          if (compressImage &&
              compressCacheWidthPx > 0 &&
              !_isGifResourceUrl(url)) {
            bytes = _processDownloadedImage(
              bytes,
              maxWidthPx: compressCacheWidthPx,
              logUrl: "$domain$url",
            );
          } else {}
          final data = TransferableTypedData.fromList([bytes]);
          mainSendPort.send([ImgIsolateKey.downLoadSuccess, url, data]);
        } else {
          mainSendPort.send([ImgIsolateKey.downLoadFail, url, "下载失败"]);
        }
      } else {
        imgeLogE("子 isolate 未知 key: $key");
      }
    });
  } catch (e, s) {
    NLog.e("子 isolate 启动异常: $e\n$s");
  }
}
