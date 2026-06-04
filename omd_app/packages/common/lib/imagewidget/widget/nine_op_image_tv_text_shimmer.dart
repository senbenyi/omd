import 'package:base/theme/app_theme.dart';
import 'package:common/imagewidget/auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// TV 频道图片未成帧占位：占位字符串横向明暗扫光（类似今日头条四字 loading）。
///
/// 字号与同包 [TvPlaceholder] 一致：`AutoSizeText` + `flutter_screenutil` 基准、`minFontSize 8`、`maxWidth * 0.72`。
class NineOpImageTvTextShimmer extends StatefulWidget {
  const NineOpImageTvTextShimmer({
    super.key,
    this.label,
    this.fontSize,
    this.maxLines = 1,
    this.duration = const Duration(milliseconds: 1680),
  });

  /// 非空则显示该文案；否则 [appChannel.appName]，仍空则固定「加载中」。
  final String? label;

  /// 与 [TvPlaceholder.fontSize] 相同语义；为 null 时使用 `40.sp`。
  final double? fontSize;

  /// 与 [TvPlaceholder.maxlIne] 相同语义。
  final int maxLines;

  final Duration duration;

  @override
  State<NineOpImageTvTextShimmer> createState() =>
      _NineOpImageTvTextShimmerState();
}

class _NineOpImageTvTextShimmerState extends State<NineOpImageTvTextShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final AutoSizeGroup _autoSizeSync = AutoSizeGroup();

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

  String _effectiveLabel() {
    final s = widget.label?.trim() ?? '';
    if (s.isNotEmpty) return s;
    final name = appChannel.appName.trim();
    if (name.isNotEmpty) return name;
    return '加载中';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _effectiveDark(context);
    final Color base =
        isDark
            ? Color.lerp(appColor.placeholderBg, const Color(0xFF3A3A3C), 0.38)!
            : appColor.placeholderBg;

    final String text = _effectiveLabel();
    final double resolvedFontSize = widget.fontSize ?? 40.sp;

    /// ① `muted`：不扫光时看到的字色——要更暗就只调这里的 alpha / 十六进制。
    final Color muted =
        isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFF47474C);

    /// ② `brightInk`：扫光带上那一层字的色——要更亮 / 更暗都调这里（已与 `muted` 解耦）。
    final Color brightInk =
        isDark ? const Color(0xFF7A7A7B) : const Color(0xFFB6B6BA);

    final TextStyle baseTvStyle = TextStyle(
      fontFamily: 'YouSheBiaoTiHei',
      fontSize: resolvedFontSize,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );

    final TextStyle mutedStyle = baseTvStyle.copyWith(color: muted);
    final TextStyle brightStyle = baseTvStyle.copyWith(
      color: brightInk,
      shadows: [
        Shadow(
          color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.022),
          blurRadius: 0,
          offset: const Offset(0, 1),
        ),
      ],
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
              final double easedMain = Curves.easeInOut.transform(raw);
              final double phase = Curves.decelerate.transform(easedMain);

              return LayoutBuilder(
                builder: (context, c) {
                  final double maxW = c.maxWidth.isFinite ? c.maxWidth : 240;

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW * 0.72),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          AutoSizeText(
                            text,
                            group: _autoSizeSync,
                            maxLines: widget.maxLines,
                            minFontSize: 8,
                            maxFontSize: double.infinity,
                            stepGranularity: 0.1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: mutedStyle,
                          ),
                          ShaderMask(
                            blendMode: BlendMode.dstIn,
                            shaderCallback: (Rect bounds) {
                              final double cx = phase * 2.75 - 1.375;
                              return LinearGradient(
                                begin: Alignment(cx - 0.48, 0),
                                end: Alignment(cx + 0.48, 0),
                                tileMode: TileMode.clamp,
                                colors: const [
                                  Color(0x00000000),
                                  Color(0x38787878),
                                  Color(0x54909090),
                                  Color(0x38787878),
                                  Color(0x00000000),
                                ],
                                stops: const [0.0, 0.36, 0.5, 0.64, 1.0],
                              ).createShader(bounds);
                            },
                            child: AutoSizeText(
                              text,
                              group: _autoSizeSync,
                              maxLines: widget.maxLines,
                              minFontSize: 8,
                              maxFontSize: double.infinity,
                              stepGranularity: 0.1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: brightStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
