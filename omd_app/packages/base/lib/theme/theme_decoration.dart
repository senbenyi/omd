import 'package:flutter/material.dart';

class ThemeDecoration {
  static BoxDecoration primaryGradient({required double radius}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        colors: [Color(0xFFFFF1E1), Color(0xFFFFFFFF)],
        begin: Alignment.topLeft, // 渐变开始点
        end: Alignment.bottomRight, // 渐变结束点
      ),
    );
  }
}
