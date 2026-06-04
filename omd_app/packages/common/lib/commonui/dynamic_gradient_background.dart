import 'package:flutter/material.dart';

/// 动态渐变背景组件
///
/// 用法示例：
/// ```dart
/// DynamicGradientBackground(
///   height: 268,
///   scrollProgress: controller.scrollProgress.value,
///   startColor: Colors.transparent,
///   midColor: Color(0xFF6B5B95),
///   endColor: Color(0xFF16151B),
///   child: YourWidget(), // 可选，可在渐变背景上放置其他组件
/// )
/// ```
class DynamicGradientBackground extends StatelessWidget {
  /// 背景高度
  final double height;

  /// 背景宽度（默认填满父容器）
  final double? width;

  /// 滚动进度值，范围 0.0 ~ 1.0
  final double scrollProgress;

  /// 顶部颜色
  final Color startColor;

  /// 中间颜色（会根据滚动进度与结束颜色插值）
  final Color midColor;

  /// 底部颜色
  final Color endColor;

  /// 渐变开始方向
  final Alignment beginAlignment;

  /// 渐变结束方向
  final Alignment endAlignment;

  /// 顶部颜色透明度
  final double startOpacity;

  /// 中间颜色透明度
  final double midOpacity;

  /// 底部颜色透明度
  final double endOpacity;

  /// 子组件（可选，可在渐变背景上叠加内容）
  final Widget? child;

  const DynamicGradientBackground({
    super.key,
    required this.height,
    required this.scrollProgress,
    required this.startColor,
    required this.midColor,
    required this.endColor,
    this.width,
    this.beginAlignment = Alignment.topCenter,
    this.endAlignment = Alignment.bottomCenter,
    this.startOpacity = 0.0,
    this.midOpacity = 0.6,
    this.endOpacity = 1.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: Stack(
        children: [
          // 动态渐变背景
          CustomPaint(
            painter: DynamicGradientPainter(
              startColor: startColor,
              midColor: midColor,
              endColor: endColor,
              scrollProgress: scrollProgress,
              beginAlignment: beginAlignment,
              endAlignment: endAlignment,
              startOpacity: startOpacity,
              midOpacity: midOpacity,
              endOpacity: endOpacity,
            ),
            size: Size.infinite,
          ),
          // 可选的子组件
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// 根据滚动进度动态改变渐变效果
class DynamicGradientPainter extends CustomPainter {
  final Color startColor;
  final Color midColor;
  final Color endColor;
  final double scrollProgress; // 滚动进度：0.0 ~ 1.0
  final Alignment beginAlignment;
  final Alignment endAlignment;
  final double startOpacity;
  final double midOpacity;
  final double endOpacity;

  DynamicGradientPainter({
    required this.startColor,
    required this.midColor,
    required this.endColor,
    required this.scrollProgress,
    this.beginAlignment = Alignment.topCenter,
    this.endAlignment = Alignment.bottomCenter,
    this.startOpacity = 0.0,
    this.midOpacity = 0.6,
    this.endOpacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 根据滚动进度插值颜色
    final interpolatedMidColor =
        Color.lerp(
          midColor.withValues(alpha: midOpacity),
          endColor.withValues(alpha: endOpacity),
          scrollProgress,
        )!;

    final paint =
        Paint()
          ..shader = LinearGradient(
            begin: beginAlignment,
            end: endAlignment,
            colors: [
              startColor.withValues(alpha: startOpacity),
              interpolatedMidColor,
              Color.lerp(
                endColor.withValues(alpha: endOpacity * 0.2),
                endColor,
                scrollProgress,
              )!,
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(DynamicGradientPainter oldDelegate) {
    // 只在关键属性变化时重绘
    if (oldDelegate.startColor != startColor) return true;
    if (oldDelegate.midColor != midColor) return true;
    if (oldDelegate.endColor != endColor) return true;
    if (oldDelegate.beginAlignment != beginAlignment) return true;
    if (oldDelegate.endAlignment != endAlignment) return true;

    // 只有当滚动进度变化超过阈值时才重绘（5%）
    if ((oldDelegate.scrollProgress - scrollProgress).abs() > 0.05) return true;

    return false;
  }
}
