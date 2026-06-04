import 'package:common/navigationbar/no_navigationbar.dart';
import 'package:base/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base/utils/app_channel.dart';

class ComicNavigationBarFactory {
  //普通带搜索导航栏
  static NoNavigationbar normalSearchNavigationBar({
    String title = "", //文字标题
    bool needBack = true,
    double? elevation,
    GestureTapCallback? onSearch,
    GestureTapCallback? onBack,
    SystemUiOverlayStyle? systemOverlayStyle,
  }) {
    return normalNavigationBar(
      elevation: elevation,
      title: title,
      needBack: needBack,
      actionWidgets: [
        GestureDetector(
          onTap: onSearch,
          child: Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Container(
              width: 40.r,
              height: 40.r,
              alignment: Alignment.center,
              child: Text(
                '\u{e7ec}',
                style: TextStyle(
                  fontFamily: 'mvfont',
                  fontSize: 24.sp,
                  color: appColor.bigTitle,
                ),
              ),
            ),
          ),
        ),
      ],
      onLeadingTap: onBack,
    );
  }

  //普通导航栏
  static NoNavigationbar normalNavigationBar({
    String title = "", //文字标题
    Widget? titleWidget, //自定义标题
    bool needBack = true,
    Widget? leadingWidget, //自定义标题
    Widget? bottom,
    double bottomHeight = 0,
    double? elevation,
    List<Widget>? actionWidgets,
    GestureTapCallback? onLeadingTap,
    Color backgroundColor = Colors.transparent,
    bool useDefaultBackImage = false,
    NineThemeMode? mode,
  }) {
    return NoNavigationbar(
      elevation: elevation,
      title: title,
      titleWidget: titleWidget,
      needBack: needBack,
      bottomHeight: bottomHeight,
      bottomWidget: bottom,
      actionWidgets: actionWidgets,
      useDefaultBackImage: useDefaultBackImage,
      backgroundColor: backgroundColor,
      mode: mode ?? appChannel.themeMode,
      leadingWidget: leadingWidget,
      onLeadingTap: onLeadingTap,
    );
  }
}
