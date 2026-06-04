import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base/theme/app_theme.dart';

class ThemeColor {
  static TextStyle get secondTabTextStyleSelected {
    return TextStyle(
      color: appColor.primary,
      fontSize: 17.sp,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle get secondTabTextStyleNormal {
    return TextStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
    );
  }

  static Color get secondTabBgColorSelected {
    return const Color(0x19FF613E);
  }

  static Color get secondTabBgColorNormal {
    return const Color.fromARGB(56, 255, 255, 255);
  }

  static Color get tabarMainColor {
    return appColor.primary;
  }

  static Color get dividerColors {
    return const Color(0xFFe5e5e5);
  }

  static SystemUiOverlayStyle get lightStatusBar {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏背景色
      statusBarIconBrightness: Brightness.dark, // 安卓：黑色图标
      statusBarBrightness: Brightness.light, // iOS：黑色图标
    );
  }

  static SystemUiOverlayStyle get darkStatusBar {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏背景色
      statusBarIconBrightness: Brightness.light, // 安卓： 白色图标
      statusBarBrightness: Brightness.dark, // iOS：白色图标
    );
  }
}
