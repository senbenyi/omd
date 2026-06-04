import 'dart:async';
import 'package:flutter/material.dart';
import 'package:common/const/app_style.dart';

class CountdownButton extends StatefulWidget {
  const CountdownButton({
    super.key,
    this.initialSeconds = 10,
    this.textStyle,
    this.backgroundColor,
    this.tipLabel = "广告",
    this.child,
    this.onClose,
    this.isClose = true,
  });

  final int initialSeconds;
  final Widget? child;
  final Color? backgroundColor;
  final VoidCallback? onClose;
  final bool isClose;
  final TextStyle? textStyle;
  final String tipLabel;

  @override
  State<CountdownButton> createState() => _CountdownButtonState();
}

class _CountdownButtonState extends State<CountdownButton> {
  late Timer _timer;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _seconds = widget.initialSeconds;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_seconds > 1) {
          _seconds--;
        } else {
          _seconds = 0;
          t.cancel();
          widget.onClose?.call();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.isClose && widget.onClose != null) widget.onClose!();
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _seconds == 0 ? "跳过" : "${widget.tipLabel} ",
                style: pingFangTextStyle.copyWith(color: Colors.white),
              ),
              TextSpan(
                text: _seconds == 0 ? "" : "$_seconds s",
                style:
                    widget.textStyle ??
                    const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
