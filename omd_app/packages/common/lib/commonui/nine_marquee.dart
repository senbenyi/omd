import 'package:base/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NineMarquee extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double velocity;

  const NineMarquee({
    super.key,
    required this.text,
    this.style,
    this.velocity = 50.0,
  });

  @override
  State<NineMarquee> createState() => _NineMarqueeState();
}

class _NineMarqueeState extends State<NineMarquee>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  double _textWidth = 0;
  double _position = 0;

  final double _spacing = 40;

  bool _visible = true;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((_) {
      if (_textWidth == 0 || !_visible) return;

      setState(() {
        _position -= widget.velocity / 60;

        final total = _textWidth + _spacing;
        if (_position <= -total) {
          _position += total;
        }
      });
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double _measureText(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle =
        widget.style ?? TextStyle(color: appColor.cardTitle, fontSize: 14.sp);

    return VisibilityDetector(
      key: Key("NineMarquee_${widget.text.hashCode}"),
      onVisibilityChanged: (info) {
        final visible = info.visibleFraction > 0.5;
        _visible = visible;
        if (_visible) {
          if (!_ticker.isActive) {
            _ticker.start();
          }
        } else {
          _ticker.stop();
        }
      },
      child: _buildContent(textStyle),
    );
  }

  Widget _buildContent(TextStyle textStyle) {
    // **首帧测量宽度**
    if (_textWidth == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _textWidth = _measureText(widget.text, textStyle);
          });
        }
      });

      return Text(widget.text, style: textStyle, maxLines: 1);
    }

    // **正常滚动**
    return OverflowBox(
      minWidth: 0,
      maxWidth: double.infinity,
      child: Transform.translate(
        offset: Offset(_position, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.text, style: textStyle),
            SizedBox(width: _spacing),
            Text(widget.text, style: textStyle),
            // 可无限加段用于超长文本更平滑
          ],
        ),
      ),
    );
  }
}
