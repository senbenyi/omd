import 'package:base/theme/my_icon_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NineIcon {
  static Widget likeIcon({
    required bool isSelected,
    double? size,
    Color? normalColor,
    Color? selectedColor,
  }) {
    return Icon(
      Icons.favorite,
      color:
          isSelected
              ? selectedColor ?? Color(0xFFEE3190)
              : normalColor ?? Colors.white,
      size: size ?? 32.w,
    );
  }

  static Widget collectIcon({
    required bool isSelected,
    double? size,
    Color? normalColor,
    Color? selectedColor,
  }) {
    return Icon(
      Icons.star,
      color:
          isSelected
              ? selectedColor ?? Color(0xFFF9CE13)
              : normalColor ?? Colors.white,
      size: size ?? 32.w,
    );
  }

  static Widget shareIcon({double? size, Color? normalColor}) {
    return Icon(
      Icons.share,
      color: normalColor ?? Colors.white,
      size: size ?? 32.w,
    );
  }

  static Widget commentIcon({double? size, Color? normalColor}) {
    return Icon(
      MyIconFont.douyinComment,
      color: normalColor ?? Colors.white,
      size: size ?? 32.w,
    );
  }
}
