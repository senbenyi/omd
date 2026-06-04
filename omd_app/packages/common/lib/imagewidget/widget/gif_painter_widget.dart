import 'dart:async';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../cache/nine_image_cache_model.dart';
import '../download_center/nine_image_provider.dart';
import '../nine_img_tool.dart';

class GifPainterWidget extends StatefulWidget {
  final Codec codec;
  final FrameInfo? firstFrmame;
  final String url;
  final String title;
  final double width;
  final double height;
  final double speedFactor;
  final int minMilliSecondsMargin;
  final Widget? placeholder;
  final double radius;
  final VoidCallback? onTap;
  final bool autoSpeed;
  final BoxFit fit;
  final Alignment alignment;

  const GifPainterWidget({
    super.key,
    required this.codec,
    required this.width,
    required this.height,
    this.speedFactor = 1.0,
    this.minMilliSecondsMargin = 0,
    this.placeholder,
    this.radius = 0,
    this.onTap,
    required this.url,
    required this.title,
    required this.autoSpeed,
    this.firstFrmame,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  State<GifPainterWidget> createState() => _GifPainterWidgetState();
}

class _GifPainterWidgetState extends State<GifPainterWidget> {
  FrameInfo? _frameInfo;
  bool _mvisible = false;
  double scaleFactor = 1.0;
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);
  NineImageCacheModel? chacheModel;
  int currentFrameIndex = 0;

  bool _disposed = false; // ⭐ 用于取消异步任务

  @override
  void initState() {
    super.initState();

    // log("XXXXXX initState");

    _frameInfo = widget.firstFrmame;
    chacheModel = NineImageProvider.instance.imageMemory.getCache(
      widget.url,
      isAd: true,
    );

    _loadCodec();
  }

  @override
  void dispose() {
    _disposed = true; // ⭐ 立即停止所有异步操作
    _frameInfo = null;
    chacheModel = null;
    _repaint.removeListener(() {});
    // log("XXXXXX dispose");
    super.dispose();
  }

  Future<void> _loadCodec() async {
    if (_disposed) return;

    try {
      if (widget.autoSpeed) {
        int frameCount = widget.codec.frameCount;
        double targetFPS = 8.0;
        if (frameCount > targetFPS) {
          scaleFactor = 1 + (frameCount - targetFPS) * 0.9 / targetFPS;
        }
      }

      if (_disposed || !mounted) return;

      _decodeNext();
    } catch (_) {}
  }

  void _decodeNext() async {
    if (_disposed || !mounted) return;
    if (!_mvisible) return;

    try {
      FrameInfo? next = chacheModel?.getFrame(currentFrameIndex);

      if (next == null) {
        next = await widget.codec.getNextFrame();
        if (_disposed || !mounted) return;
        chacheModel?.addFrame(next, currentFrameIndex);
      }

      if (_disposed || !mounted) return;

      _frameInfo = next;
      _repaint.value++;

      // 获取当前帧的延迟时间
      final int duration = next.duration.inMilliseconds;
      // 应用速度因子和最小延迟
      final int delay = ((duration * widget.speedFactor * scaleFactor).round())
          .clamp(widget.minMilliSecondsMargin, 10000);

      currentFrameIndex = (currentFrameIndex + 1) % widget.codec.frameCount;

      // 根据帧延迟时间，在指定时间后继续播放下一帧
      Future.delayed(Duration(milliseconds: delay), () {
        if (_disposed || !mounted) return;
        if (_mvisible) {
          _decodeNext();
        }
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        final nowVisible = info.visibleFraction > 0.5;

        if (_mvisible == nowVisible) return;

        _mvisible = nowVisible;

        log("visiable改变 $_mvisible");

        if (_mvisible) {
          _decodeNext();
        }
      },
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: CustomPaint(
          painter: _SmoothGifPainter(
            frameProvider: () => _frameInfo?.image,
            radius: widget.radius,
            repaint: _repaint,
            width: widget.width,
            height: widget.height,
            title: widget.title,
            fit: widget.fit,
            alignment: widget.alignment,
          ),
        ),
      ),
    );
  }

  log(String msg) {
    imgeLogD("$msg ${widget.title.isEmpty ? "测试" : widget.title}");
  }
}

class _SmoothGifPainter extends CustomPainter {
  final ui.Image? Function() frameProvider;
  final double radius;
  final double width;
  final double height;
  final String title;
  final BoxFit fit;
  final Alignment alignment;

  _SmoothGifPainter({
    required this.width,
    required this.height,
    required this.title,
    required this.frameProvider,
    required this.radius,
    required this.fit,
    required this.alignment,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final ui.Image? img = frameProvider();
    if (img == null) return;

    final imgW = img.width.toDouble();
    final imgH = img.height.toDouble();
    final paint = Paint();

    final outputSize = size;
    final inputSize = Size(imgW, imgH);

    /// 圆角裁剪
    canvas.save();
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & outputSize,
      Radius.circular(radius),
    );
    canvas.clipRRect(rrect);

    /// ========== 1. 计算 srcRect & dstRect（确保不变形，裁剪铺满） ==========
    Rect srcRect;
    Rect dstRect;

    if (fit == BoxFit.cover) {
      // BoxFit.cover: 保持宽高比，缩放以完全覆盖目标区域，可能裁剪
      final double scaleX = outputSize.width / inputSize.width;
      final double scaleY = outputSize.height / inputSize.height;
      // 使用较大的缩放比例，确保完全覆盖
      final double scale = scaleX > scaleY ? scaleX : scaleY;

      // 目标区域始终铺满
      dstRect = Offset.zero & outputSize;

      // 计算源图片需要裁剪的区域
      // 缩放后图片在目标区域中显示的部分对应的源图片区域
      final double srcWidth = outputSize.width / scale;
      final double srcHeight = outputSize.height / scale;

      // 计算源图片中超出显示区域的部分（需要裁剪的）
      final double excessWidth = inputSize.width - srcWidth;
      final double excessHeight = inputSize.height - srcHeight;

      // 根据 alignment 计算裁剪偏移
      // alignment.x: -1(左) 到 1(右), alignment.y: -1(上) 到 1(下)
      // 当 alignment.x = -1 (左对齐) 时，srcOffsetX = 0
      // 当 alignment.x = 1 (右对齐) 时，srcOffsetX = excessWidth
      // 当 alignment.x = 0 (居中) 时，srcOffsetX = excessWidth / 2
      final double srcOffsetX =
          excessWidth > 0 ? (excessWidth / 2) * (1 + alignment.x) : 0;
      final double srcOffsetY =
          excessHeight > 0 ? (excessHeight / 2) * (1 + alignment.y) : 0;

      srcRect = Rect.fromLTWH(srcOffsetX, srcOffsetY, srcWidth, srcHeight);
    } else {
      // 其他 fit 模式使用标准方法
      final FittedSizes fitted = applyBoxFit(fit, inputSize, outputSize);
      final Size srcSize = fitted.source;
      final Size dstSize = fitted.destination;
      srcRect = alignment.inscribe(srcSize, Offset.zero & inputSize);
      dstRect = alignment.inscribe(dstSize, Offset.zero & outputSize);
    }

    /// ========== 2. 绘制 ==========
    // 使用高质量过滤，确保图片清晰度
    paint.filterQuality = FilterQuality.high;
    // 启用抗锯齿，提升图片质量
    paint.isAntiAlias = true;
    canvas.drawImageRect(img, srcRect, dstRect, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SmoothGifPainter oldDelegate) => true;
}
