import 'dart:typed_data';

import 'package:base/theme/app_theme.dart';
import 'package:base/utils/app_channel.dart';
import 'package:common/imagewidget/download_center/nine_image_provider.dart';
import 'package:common/imagewidget/nine_image_background.dart';
import 'package:common/imagewidget/widget/nine_op_image_tv_text_shimmer.dart';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NineopImage extends StatefulWidget {
  const NineopImage({
    super.key,
    required this.url,
    this.title = "",
    this.width,
    this.height,
    this.fit = BoxFit.fill,
    this.onTap,
    this.alignment,
    this.radius = 0,
    this.placeholder,
    this.onImageBytesReady,
    this.cacheWidth,
    this.cacheHeight,
    this.borderRadius,
    this.backgroundColor,
  });

  final String url;
  final String title;
  final double? width;
  final double? height;
  final Alignment? alignment;
  final BoxFit fit;
  final VoidCallback? onTap;
  final double? radius;
  final Widget? placeholder;
  final ValueChanged<Uint8List>? onImageBytesReady;
  final int? cacheWidth;
  final int? cacheHeight;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  @override
  State<NineopImage> createState() => _NineopImageState();
}

class _NineopImageState extends State<NineopImage> {
  /// 最后一帧 [Image.memory] 解码失败等，用于「再次可见」时补拉。
  bool _decodeFailed = false;

  /// 是否正在走 [requestImageData] / 等首包（与 UI 扫光一致）。
  bool _memoryResolving = false;

  Uint8List? _bytes;

  /// [VisibilityDetector]：>0.1 为可见；不可见时不做失败后的第二次请求。
  bool _visibleEnough = false;

  /// 上一回调是否已达可见阈值，用于检测「再次可见」边沿。
  bool _wasVisibleEnough = false;

  /// 仅在一次「因失败而用户划回可见」触发的重拉时递增，刷新 [VisibilityDetector] key。
  int _reloadGeneration = 0;

  Object? _loadToken;

  @override
  void initState() {
    super.initState();
    _memoryResolving = widget.url.trim().isNotEmpty;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMemoryImage());
  }

  @override
  void didUpdateWidget(NineopImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      NineImageProvider.instance.changePriority(oldWidget.url, 0);
      _decodeFailed = false;
      _reloadGeneration = 0;
      _wasVisibleEnough = false;
      _visibleEnough = false;
      _bytes = null;
      _memoryResolving = widget.url.trim().isNotEmpty;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadMemoryImage());
    }
  }

  @override
  void dispose() {
    NineImageProvider.instance.changePriority(widget.url, 0);
    _loadToken = null;
    super.dispose();
  }

  Future<Uint8List?> _requestImageBytes(String url) {
    return NineImageProvider.instance.requestImageData(
      url,
      isAd: false,
      needDecrypt: needDecrypt(),
      compressImage: appChannel.channleType != ChannelType.tv,
      cacheWidth: widget.cacheWidth,
      title: widget.title,
    );
  }

  /// 单次完整的网络拉取：可见时首包失败会再请求一次；不可见时从不做第二次请求。
  Future<void> _loadMemoryImage() async {
    final String url = widget.url.trim();
    if (url.isEmpty) {
      if (!mounted) return;
      setState(() {
        _bytes = null;
        _memoryResolving = false;
      });
      return;
    }

    final token = Object();
    _loadToken = token;
    if (!mounted) return;
    setState(() {
      _memoryResolving = true;
      _decodeFailed = false;
    });

    Uint8List? data;
    if (!mounted || _loadToken != token) return;

    data = await _requestImageBytes(url);
    if (!mounted || _loadToken != token) return;

    if ((data == null || data.isEmpty) && _visibleEnough) {
      data = await _requestImageBytes(url);
    }
    if (!mounted || _loadToken != token) return;

    if (data == null || data.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _recordDecodeFailed();
      });
      setState(() {
        _bytes = null;
        _memoryResolving = false;
      });
      return;
    }

    widget.onImageBytesReady?.call(data);

    if (!mounted || _loadToken != token) return;
    setState(() {
      _bytes = data;
      _memoryResolving = false;
    });
  }

  /// 从不可见 → 可见边沿：若上次失败且当前空闲，再整轮拉取（含可见时的最多两次请求）。
  void _tryReloadAfterBecameVisibleAgain() {
    if (!mounted) return;
    final String url = widget.url.trim();
    if (url.isEmpty || _memoryResolving || !_decodeFailed) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final String u = widget.url.trim();
      if (u.isEmpty || _memoryResolving || !_decodeFailed) return;
      setState(() {
        _reloadGeneration++;
        _bytes = null;
      });
      _loadMemoryImage();
    });
  }

  void _recordDecodeFailed() {
    if (!mounted || _decodeFailed) return;
    setState(() {
      _decodeFailed = true;
    });
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    final bool visible = info.visibleFraction > 0.1;
    _visibleEnough = visible;
    NineImageProvider.instance.changePriority(widget.url, visible ? 2 : 1);

    final bool becameVisible = visible && !_wasVisibleEnough;
    _wasVisibleEnough = visible;

    if (becameVisible) {
      _tryReloadAfterBecameVisibleAgain();
    }
  }

  bool needDecrypt() {
    if (appChannel.channleType == ChannelType.tv) {
      if (widget.url.contains(".js")) {
        return true;
      }
      return false;
    }
    return true;
  }

  Widget _buildImageLayer() {
    final String url = widget.url.trim();
    if (url.isEmpty || (_decodeFailed && _bytes == null && !_memoryResolving)) {
      return widget.placeholder ?? const SizedBox.shrink();
    }

    final bool showShimmer = _memoryResolving || _bytes == null;

    final Widget decoded =
        showShimmer
            ? (appChannel.channleType == ChannelType.tv
                ? NineOpImageTvTextShimmer(label: appChannel.placeHolderDomain)
                : widget.placeholder ?? SizedBox.shrink())
            : Image.memory(
              _bytes!,
              gaplessPlayback: true,
              fit: widget.fit,
              alignment: widget.alignment ?? Alignment.topCenter,
              cacheWidth: widget.cacheWidth,
              cacheHeight: widget.cacheHeight,
              frameBuilder: (
                BuildContext context,
                Widget child,
                int? frame,
                bool wasSynchronouslyLoaded,
              ) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 120),
                  child: child,
                );
              },
              errorBuilder: (context, error, stackTrace) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _recordDecodeFailed();
                });
                return const SizedBox.shrink();
              },
            );

    return decoded;
  }

  BorderRadius get _borderRadius {
    if (widget.borderRadius != null) {
      return widget.borderRadius!;
    }
    if (widget.radius != null && widget.radius! > 0) {
      return BorderRadius.circular(widget.radius!);
    }
    return BorderRadius.zero;
  }

  Color get _backgroundColor =>
      NineImageBackground.resolve(widget.backgroundColor);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: _borderRadius,
        clipBehavior: Clip.hardEdge,
        child: ColoredBox(
          color: _backgroundColor,
          child: VisibilityDetector(
            onVisibilityChanged: _handleVisibilityChanged,
            key: ValueKey<String>('${widget.url}_$_reloadGeneration'),
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final Widget imageLayer = _buildImageLayer();
    if (widget.placeholder == null) {
      return imageLayer;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW =
            _finiteOrNull(widget.width) ?? _finiteOrNull(constraints.maxWidth);
        final maxH =
            _finiteOrNull(widget.height) ??
            _finiteOrNull(constraints.maxHeight);
        if (maxW != null && maxH != null) {
          return SizedBox(
            width: maxW,
            height: maxH,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(child: widget.placeholder!),
                Positioned.fill(child: imageLayer),
              ],
            ),
          );
        }

        return Stack(
          fit: StackFit.passthrough,
          children: [Positioned.fill(child: widget.placeholder!), imageLayer],
        );
      },
    );
  }

  static double? _finiteOrNull(double? value) {
    if (value == null || !value.isFinite) return null;
    return value;
  }
}
