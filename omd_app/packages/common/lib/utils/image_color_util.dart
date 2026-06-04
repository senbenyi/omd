import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:base/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'crypto_util.dart';

//https://juejin.cn/post/7526555265039269928
class ImageColorUtil {
  static final Map<String, Color> _colorCache = {};
  static final Map<String, _ImageData> _imageCache = {};
  static const int _maxCacheSize = 50;

  /// 获取图片主色入口
  static Future<Color> getMainColorFromUrl(String url) async {
    if (url.isEmpty) {
      return appColor.placeHolderCard;
    }
    if (_colorCache.containsKey(url)) return _colorCache[url]!;

    try {
      // 先加载图片数据（缓存 & 解密）
      final _ImageData imageData = await _loadImage(url);
      // 从ImageProvider计算主色
      final color = await _getColorFromImageProvider(imageData.provider, url);
      return color;
    } catch (e) {
      // debugPrint('获取图片主色失败: $e');
      return Colors.grey;
    }
  }

  static Future<Color> getMainColorFromBytes(
    Uint8List bytes, {
    String? cacheKey,
  }) async {
    if (bytes.isEmpty) {
      return appColor.placeHolderCard;
    }
    if (cacheKey != null && _colorCache.containsKey(cacheKey)) {
      return _colorCache[cacheKey]!;
    }
    try {
      final color = await _getColorFromImageProvider(
        MemoryImage(bytes),
        cacheKey ?? '',
      );
      if (cacheKey != null) {
        _colorCache[cacheKey] = color;
      }
      return color;
    } catch (_) {
      return Colors.grey;
    }
  }

  /// 加载图片并缓存
  static Future<_ImageData> _loadImage(String url) async {
    if (_imageCache.containsKey(url)) {
      // 实现LRU逻辑：先移除后重新添加，保证最新
      final item = _imageCache.remove(url);
      if (item != null) {
        _imageCache[url] = item;
        return item;
      }
    }

    try {
      final bytes = await CryptoUtil.fetchAndDecrypt(url);
      final size = await _getImageSize(bytes);
      final image = MemoryImage(bytes);

      if (_imageCache.length >= _maxCacheSize) {
        _imageCache.remove(_imageCache.keys.first);
      }

      final data = _ImageData(provider: image, size: size);
      _imageCache[url] = data;
      return data;
    } catch (e) {
      throw Exception("Image load failed");
    }
  }

  /// 从 ImageProvider 计算图片主色（平均色）
  static Future<Color> _getColorFromImageProvider(
    ImageProvider provider,
    String url,
  ) async {
    // ImageSelector imageSelector = ImageSelector();

    final ui.Image image = await _getUiImage(provider);

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (byteData == null) return Colors.grey;

    final Uint8List pixels = byteData.buffer.asUint8List();

    int rSum = 0, gSum = 0, bSum = 0, pixelCount = 0;

    for (int i = 0; i < pixels.length; i += 4) {
      final int alpha = pixels[i + 3];
      if (alpha > 0) {
        rSum += pixels[i];
        gSum += pixels[i + 1];
        bSum += pixels[i + 2];
        pixelCount++;
      }
    }

    if (pixelCount == 0) return Colors.grey;

    final int r = (rSum / pixelCount).round();
    final int g = (gSum / pixelCount).round();
    final int b = (bSum / pixelCount).round();

    final color = Color.fromARGB(255, r, g, b);
    if (url.isNotEmpty) {
      _colorCache[url] = color;
    }
    return color;
  }

  /// 通过 ImageProvider 异步获取 ui.Image
  static Future<ui.Image> _getUiImage(ImageProvider provider) async {
    final Completer<ui.Image> completer = Completer();

    final ImageStream stream = provider.resolve(const ImageConfiguration());

    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (error, _) {
        completer.completeError(error);
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);
    return completer.future;
  }

  static Future<Size> _getImageSize(Uint8List bytes) async {
    final codec = await instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return Size(frame.image.width.toDouble(), frame.image.height.toDouble());
  }
}

class _ImageData {
  final ImageProvider provider;
  final Size size;

  _ImageData({required this.provider, required this.size});
}
