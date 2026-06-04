import 'dart:ui' as ui;

import 'package:common/imagewidget/download_center/nine_image_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// [Image.resolve] 时的解析键：与 [EncryptedImageProvider] 实例一致。
@immutable
class EncryptedImageResolveKey {
  const EncryptedImageResolveKey({required this.provider});

  final EncryptedImageProvider provider;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncryptedImageResolveKey && other.provider == provider;

  @override
  int get hashCode => provider.hashCode;
}

/// 离线拉流 + 解码链路状态（不向 [operator ==]/[hashCode] 纳入回调，避免每次 build 换新闭包导致缓存失效）。
enum ImageLoadStatus {
  loading,
  success,
  error,
}

class EncryptedImageProvider extends ImageProvider<EncryptedImageResolveKey> {
  final String url;
  final String title;
  final bool isAd;
  final bool needDecrypt;
  final bool compressImage;
  final void Function(Uint8List? bytes)? onBytesReady;
  final int? cacheWidth;
  final int? cacheHeight;

  /// 下载开始、解码结束或失败时的通知（不包含在相等性比较中）。
  final void Function(ImageLoadStatus status)? onLoading;
  final int reloadGeneration;

  const EncryptedImageProvider({
    required this.url,
    this.isAd = false,
    this.needDecrypt = true,
    this.compressImage = false,
    this.onBytesReady,
    this.cacheWidth,
    this.cacheHeight,
    required this.title,
    this.reloadGeneration = 0,
    this.onLoading,
  });

  @override
  Future<EncryptedImageResolveKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(EncryptedImageResolveKey(provider: this));
  }

  @override
  ImageStreamCompleter loadImage(
    EncryptedImageResolveKey key,
    ImageDecoderCallback decode,
  ) {
    final p = key.provider;
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      debugLabel: p.url,
    );
  }

  Future<ui.Codec> _loadAsync(
    EncryptedImageResolveKey key,
    ImageDecoderCallback decode,
  ) async {
    final p = key.provider;
    p.onLoading?.call(ImageLoadStatus.loading);

    Uint8List? bytes;
    try {
      bytes = await NineImageProvider.instance.requestImageData(
        p.url,
        isAd: p.isAd,
        needDecrypt: p.needDecrypt,
        compressImage: p.compressImage,
        cacheWidth: p.cacheWidth,
        title: p.title,
      );
    } catch (_) {
      p.onLoading?.call(ImageLoadStatus.error);
      rethrow;
    }

    try {
      p.onBytesReady?.call(bytes);
    } catch (_) {}

    if (bytes == null || bytes.isEmpty) {
      p.onLoading?.call(ImageLoadStatus.error);
      throw StateError('Image bytes empty: ${p.url}');
    }

    try {
      final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(
        bytes,
      );

      final ui.Codec codec = await decode(
        buffer,
        getTargetSize: (int intrinsicWidth, int intrinsicHeight) {
          final bool isolateResizedByWidth =
              p.compressImage &&
              p.cacheWidth != null &&
              p.cacheWidth! > 0;
          if (isolateResizedByWidth) {
            return const ui.TargetImageSize();
          }
          return ui.TargetImageSize(
            width: p.cacheWidth,
            height: p.cacheHeight,
          );
        },
      );
      p.onLoading?.call(ImageLoadStatus.success);
      return codec;
    } catch (_) {
      p.onLoading?.call(ImageLoadStatus.error);
      rethrow;
    }
  }

  /// 不包含 [onBytesReady] / [onLoading]，避免因闭包变换导致同一 URL 绕过 [ImageCache]。
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncryptedImageProvider &&
          other.url == url &&
          other.isAd == isAd &&
          other.needDecrypt == needDecrypt &&
          other.compressImage == compressImage &&
          other.cacheWidth == cacheWidth &&
          other.cacheHeight == cacheHeight &&
          other.title == title &&
          other.reloadGeneration == reloadGeneration;

  @override
  int get hashCode => Object.hash(
    url,
    isAd,
    needDecrypt,
    compressImage,
    cacheWidth,
    cacheHeight,
    title,
    reloadGeneration,
  );
}
