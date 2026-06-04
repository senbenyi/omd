import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NineTextStyle {
  static String fontFamilyDIN = "DIN-Alternate-Bold";
  static String fontFamilyPingFang = "PingFang SC";
  static String fontFamilyHYYakuHei = "HYYakuHei";
  static String fontFamilyYouSheBiaoTiHei2 = "YouSheBiaoTiHei-2";
  static String fontFamilyMyFont2 = "mvfont";
  static String fontFamilyBarlow = "Barlow";
  static List<String> fontFamilyFallback = [
    "MiSans",
    "SF Pro Text",
    "Noto Sans",
    "Roboto",
  ];
  static TextStyle get comicItemText {
    return TextStyle(
      color: Colors.white,
      fontFamily: fontFamilyPingFang,
      fontSize: 14.sp,
      fontFamilyFallback: fontFamilyFallback,
    );
  }
  static TextStyle get videoIconButtonText {
    return TextStyle(
      color: Colors.white,
      fontFamily: fontFamilyPingFang,
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      fontFamilyFallback: fontFamilyFallback,
    );
  }

  static TextStyle get videoTitle {
    return TextStyle(
      color: Colors.white,
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      fontFamily: fontFamilyPingFang,
    );
  }

  static TextStyle get videoContent {
    return TextStyle(
      color: Colors.white,
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      fontFamily: fontFamilyPingFang,
    );
  }

  static double videCarWidth = (Get.mediaQuery.size.width - 24.w - 8.w) / 2;
  static double videImgHeight = videCarWidth * 9.0 / 16.0;
  static double videCardHeight = videImgHeight + 45.w;
  static double videCardAspectRati = videCarWidth / videCardHeight;
}
