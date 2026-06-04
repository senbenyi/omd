import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:common/imagewidget/download_center/nine_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// --- 问题关键修复点 ---
/// 1. 初始不再立即加载图片，而是等待第一帧构建完成
/// 2. 确保占位图至少显示一帧（WidgetsBinding.instance.addPostFrameCallback）
/// 3. 避免占位图还没渲染就被 reverse() 隐藏

class NineAutoImage extends StatefulWidget {
  final String url;
  final String title;
  final Widget? placeholder;
  final double width;
  final double? height;
  final double preWidth; // 预占位宽度
  final double preHeight; // 预占位高度
  final BoxFit fit;
  final Alignment? alignment;
  final VoidCallback? onTap;

  final double radius;
  final bool autoSpeed;
  final bool forceUseGif;
  final bool needLoading;
  final Function(double origWidth, double origHeight, double displayedHeight)?
  onLoadImageComplete;

  const NineAutoImage({
    super.key,
    required this.url,
    this.title = "",
    required this.width,
    this.height,
    this.fit = BoxFit.fill,
    this.placeholder,
    this.onTap,
    this.alignment,
    this.radius = 0,
    this.autoSpeed = true,
    this.forceUseGif = true,
    required this.preWidth,
    required this.preHeight,
    this.onLoadImageComplete,
    this.needLoading = false,
  });

  @override
  State<NineAutoImage> createState() => _NineAutoImageState();
}

class _NineAutoImageState extends State<NineAutoImage>
    with TickerProviderStateMixin {
  ui.Image? _myImage;
  double? _imageHeight;
  bool _loading = false;
  bool _hasError = false;
  late final AnimationController _imageCtrl;
  late final Animation<double> _imageOpacity;
  bool showPlace = true;

  @override
  void initState() {
    super.initState();
    _imageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 0.0,
    );
    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_imageCtrl);

    // 直接开始加载数据（占位图会在 build 时显示，因为 controller 值为 1）
    // _getImageData();
  }

  @override
  void didUpdateWidget(covariant NineAutoImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _reset();
      _getImageData();
    }
  }

  void _reset() {
    _myImage = null;
    _imageHeight = null;
    _hasError = false;
    _imageCtrl.value = 0.0;
  }

  Future<void> _getImageData() async {
    if (_loading) return;
    _loading = true;
    _hasError = false;

    try {
      final Uint8List? imageData = await NineImageProvider.instance
          .requestImageData(
            widget.url,
          );

      if (!mounted) return;

      if (imageData == null) {
        _loading = false;
        if (widget.needLoading) {
          setState(() {});
        }
        return;
      }

      // decodeImageFromList 可能抛异常
      ui.Image decoded;
      try {
        decoded = await decodeImageFromList(imageData);
      } catch (e) {
        if (!mounted) return;
        _loading = false;
        setState(() => _hasError = true);
        return;
      }
      _loading = false;
      if (!mounted) return;

      // 保存 image 并计算显示高度
      _myImage = decoded;
      final double imgW = decoded.width.toDouble();
      final double imgH = decoded.height.toDouble();
      _imageHeight =
          (imgW <= 0) ? widget.preHeight : widget.width * (imgH / imgW);

      widget.onLoadImageComplete?.call(
        decoded.width.toDouble(),
        decoded.height.toDouble(),
        _imageHeight!,
      );

      // 关键：只有在图片成功 decode 后才触发过渡动画（占位 -> 图片）
      // 这样会保证占位图从一开始可见，直到图片准备好再淡出。
      if (mounted) {
        // 触发动画：占位淡出，图片淡入
        _imageCtrl.forward();
        setState(() {});
        Future.delayed(Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              showPlace = false;
            });
          }
        });
      }
    } finally {}
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.1;
    NineImageProvider.instance.changePriority(widget.url, visible ? 2 : 1);
    if (visible && _myImage == null && !_loading && !_hasError) {
      _getImageData();
    }
  }

  @override
  void dispose() {
    NineImageProvider.instance.changePriority(widget.url, 0);
    _imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double showHeight = _imageHeight ?? widget.preHeight;
    return VisibilityDetector(
      key: ValueKey(widget.url),
      onVisibilityChanged: _onVisibilityChanged,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            width: widget.width,
            height: showHeight,
            child: Stack(
              children: [
                if (showPlace)
                  SizedBox(
                    width: widget.width,
                    height: widget.preHeight,
                    child: widget.placeholder,
                  ),
                // 图片 —— 当 _myImage 准备好再显示（通过 opacity 淡入）
                _myImage == null
                    ? const SizedBox()
                    : FadeTransition(
                      opacity: _imageOpacity,
                      child: RawImage(
                        image: _myImage,
                        width: widget.width,
                        height: _imageHeight ?? widget.preHeight,
                        fit: widget.fit,
                        alignment: widget.alignment ?? Alignment.topCenter,
                      ),
                    ),
                // 可选：错误显示
                if (_loading && widget.needLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
