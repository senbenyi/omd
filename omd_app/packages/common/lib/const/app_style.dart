import 'package:base/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:common/const/app_dimen.dart';
import 'package:common/const/app_string.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final pingFangTextStyle = TextStyle(
  color: appColor.cardTitle,
  fontFamily: fontFamilyPingFang,
  fontFamilyFallback: ["MiSans", "SF Pro Text", "Noto Sans", "Roboto"],
);

final numberTextStyle = TextStyle(fontFamily: fontFamilyDIN);

class AppTextStyle {
  AppTextStyle._internal();

  static TextStyle eb445a_s12 = build(Colors.white, 12);

  static TextStyle a8a8a5_s14 = build(const Color(0xff8a8aa5), 15);
  static TextStyle white_s14 = build(Colors.white, 14);

  static TextStyle durationTextStyle = build(
    Colors.white,
    10,
    fontFamily: fontFamilyDIN,
    fontWeight: FontWeight.w600,
  );

  static TextStyle build(
    Color color,
    double fontSize, {
    FontWeight fontWeight = FontWeight.normal,
    String? fontFamily,
    double? height,
    TextOverflow? overflow = TextOverflow.ellipsis,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: decoration,
      height: height,
      overflow: overflow,
    );
  }

  static TextStyle build125({
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? fontSize,
    double? height,
    String? fontFamily,
    TextOverflow? overflow = TextOverflow.ellipsis,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return TextStyle(
      color: Colors.white,
      fontSize: fontSize ?? 14.sp,
      fontWeight: fontWeight,
      decoration: decoration,
      height: height ?? 1.25,
      overflow: overflow,
    );
  }

  static TextStyle defaultStyle = TextStyle(
    fontSize: AppDimen.sp(14),
    color: Colors.white,
    overflow: TextOverflow.ellipsis,
  );

  static TextStyle textContentStyle = TextStyle(
    // fontSize: AppColor.textSm,
    // color: AppColor.textContent,
    fontWeight: FontWeight.normal,
    height: 1.25,
  );

  static TextStyle textLargeStyle = textContentStyle.copyWith(
    // fontSize: AppColor.textBase,
  );
  static TextStyle textSmallStyle = textContentStyle.copyWith(
    // fontSize: AppColor.textXs,
  );

  static TextStyle textStyle = pingFangTextStyle.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: 12.sp,
  );

  // 一级tab默认样式
  static TextStyle level1TabStyle = pingFangTextStyle.copyWith(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );

  // 一级tab激活样式
  static TextStyle level1TabActiveStyle = pingFangTextStyle.copyWith(
    fontSize: 17.sp,
    fontWeight: FontWeight.w800,
  );

  // 二级tab默认样式
  static TextStyle level2TabStyle = pingFangTextStyle.copyWith(
    fontSize: 13.sp,
    color: const Color(0xff969699),
    fontWeight: FontWeight.w400,
  );

  // 二级tab激活样式
  static TextStyle level2TabActiveStyle = pingFangTextStyle.copyWith(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle videoTitleTextStyle = pingFangTextStyle.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: 13.sp,
  );
  static TextStyle videoSubTitleTextStyle = pingFangTextStyle.copyWith(
    color: appColor.cardSecondary,
    fontSize: 11.sp,
  );

  static TextStyle videoNumberTextStyle = numberTextStyle.copyWith(
    fontSize: 13.sp,
  );
  static TextStyle videoSubNumberTextStyle = numberTextStyle.copyWith(
    fontSize: 11.sp,
  );

  static TextStyle tabTextStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.56),
    fontSize: 14.sp,
    fontFamily: fontFamilyPingFang,
    fontWeight: FontWeight.w400,
  );

  static TextStyle activeTabTextStyle = tabTextStyle.copyWith(
    color: Colors.white,
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle categoryTabTextStyle = textStyle;
  static TextStyle activeCategoryTabTextStyle = categoryTabTextStyle.copyWith(
    color: const Color(0xFFFF7700),
  );

  static BoxDecoration activeCategoryTabBackgroundStyle = BoxDecoration(
    color: const Color(0xFFFF613E).withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(4),
  );

  static BoxDecoration categoryTabBackgroundStyle =
      activeCategoryTabBackgroundStyle.copyWith(color: const Color(0xFFFF613E));
}
