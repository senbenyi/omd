import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatioUtil {
  static Size getComicRatio({double spacing = 34, double ratio = 240 / 354, int count = 3}) {
    double width = (1.sw - spacing.w) / count;
    double height = width / ratio;
    return Size(width, height);
  }

  static Size getVideoRatio({required double spacing, required double ratio, int count = 1}) {
    double width = (1.sw - spacing.w) / count;
    double height = width / ratio;
    return Size(width, height);
  }
}
