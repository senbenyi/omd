import 'package:base/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base/utils/app_channel.dart';

class HeaderWidget extends StatelessWidget {
  final String? title;
  final String moreText;
  final double height;

  // final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onPressed;

  const HeaderWidget({
    super.key,
    this.title,
    this.moreText = '查看更多',
    this.height = 30,
    this.padding,
    this.onPressed,
  });

  bool get isLight => appChannel.themeMode == NineThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.w,
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title ?? '',
            style: TextStyle(
              color: appColor.bigTitle,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onPressed != null)
            InkWell(
              onTap: onPressed,

              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                decoration:
                    isLight
                        ? null
                        : BoxDecoration(
                          color: const Color(0xFF232325),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                alignment: Alignment.center,
                child: Row(
                  spacing: 5.w,
                  children: [
                    Text(
                      moreText,
                      style: TextStyle(
                        color: appColor.cardTitle,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12.sp,
                      color: appColor.cardTitle,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
