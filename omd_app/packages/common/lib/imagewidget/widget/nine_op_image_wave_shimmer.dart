import 'dart:math' as math;

import 'package:base/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// [NineopImage] 等未成帧时的占位：水平方向扫光（无斜向旋转），暗色模式略提亮基底。
class NineOpImageWaveShimmer extends StatefulWidget {
  const NineOpImageWaveShimmer({
    super.key,
    /// 略长周期 + 非线性相位，避免匀速显得生硬。
    this.duration = const Duration(milliseconds: 2400),
  });

  final Duration duration;

  @override
  State<NineOpImageWaveShimmer> createState() => _NineOpImageWaveShimmerState();
}

class _NineOpImageWaveShimmerState extends State<NineOpImageWaveShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active = TickerMode.of(context);
    if (active && !_controller.isAnimating) {
      _controller.repeat();
    }
    if (!active) _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _effectiveDark(BuildContext context) {
    try {
      return Theme.of(context).brightness == Brightness.dark;
    } catch (_) {
      return appChannel.isDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _effectiveDark(context);

    /// 暗色：整体略提亮，避免过于接近纯黑。
    final Color base = isDark
        ? Color.lerp(appColor.placeholderBg, const Color(0xFF3A3A3C), 0.38)!
        : appColor.placeholderBg;

    final double crestMix = isDark ? 0.22 : 0.18;
    final Color crest = Color.lerp(base, Colors.white, crestMix)!.withValues(
      alpha: isDark ? 0.15 : 0.26,
    );

    return RepaintBoundary(
      child: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: ColoredBox(
          color: base,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              final double raw = _controller.value.clamp(0.0, 1.0);
              /// 中间略快、两端更缓；再叠加 decelerate，扫到终点前自然减速。
              final double easedMain = Curves.easeInOut.transform(raw);
              final double phase = Curves.decelerate.transform(easedMain);
              /// 仅轻微竖向颤动，主轴仍是横向平移。
              final double yRipple =
                  math.sin(raw * math.pi * 2 * 3.8) * (isDark ? 0.7 : 0.85);

              return CustomPaint(
                painter: _HorizontalWaveBandPainter(
                  progress: phase,
                  yRipplePx: yRipple,
                  baseColor: base,
                  crestColor: crest,
                  isDarkTheme: isDark,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HorizontalWaveBandPainter extends CustomPainter {
  _HorizontalWaveBandPainter({
    required this.progress,
    required this.yRipplePx,
    required this.baseColor,
    required this.crestColor,
    required this.isDarkTheme,
  });

  /// 水平相位 0..1。
  final double progress;
  final double yRipplePx;

  final Color baseColor;
  final Color crestColor;
  final bool isDarkTheme;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rect = Offset.zero & size;

    canvas.saveLayer(rect, Paint());

    final double travelPx =
        -(size.width * 0.55) + progress * (size.width * 1.45);

    canvas.translate(travelPx, yRipplePx);

    final double bandWidth =
        math.max(size.width * 2.8, size.height * 2.6);
    final Rect bandRect = Rect.fromCenter(
      center: Offset.zero,
      width: bandWidth,
      height: size.height * 4,
    );

    /// 纯水平渐变，无 Rotation。
    final shader = LinearGradient(
      tileMode: TileMode.clamp,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        baseColor.withValues(alpha: 0),
        crestColor.withValues(
          alpha: crestColor.a * (isDarkTheme ? 0.48 : 0.58),
        ),
        crestColor.withValues(
          alpha: crestColor.a * (isDarkTheme ? 0.16 : 0.26),
        ),
        baseColor.withValues(alpha: 0),
      ],
      stops: const [0.42, 0.493, 0.507, 0.575],
    ).createShader(bandRect);

    final Paint overlay = Paint()
      ..shader = shader
      ..blendMode = BlendMode.plus
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        isDarkTheme ? 13.5 : 12,
      );

    canvas.drawRect(bandRect, overlay);

    /// 竖向 DstIn：上下渐隐，避免扫光条上下完全贯穿占位区。
    final Rect localViewport = Rect.fromLTWH(
      -travelPx,
      -yRipplePx,
      size.width,
      size.height,
    );
    canvas.drawRect(
      localViewport,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.45),
            Colors.white.withValues(alpha: 1),
            Colors.white.withValues(alpha: 1),
            Colors.white.withValues(alpha: 0.45),
            Colors.transparent,
          ],
          stops: const [0.0, 0.18, 0.32, 0.68, 0.82, 1.0],
        ).createShader(localViewport),
    );

    canvas.restore();

    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.softLight
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withValues(alpha: isDarkTheme ? 0.09 : 0.07),
            Colors.transparent,
            baseColor.withValues(alpha: isDarkTheme ? 0.085 : 0.055),
          ],
          stops: const [0, 0.52, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _HorizontalWaveBandPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.yRipplePx != yRipplePx ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.crestColor != crestColor ||
        oldDelegate.isDarkTheme != isDarkTheme;
  }
}
