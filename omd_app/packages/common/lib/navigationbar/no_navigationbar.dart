import 'package:base/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/route_manager.dart';
import 'package:base/utils/app_channel.dart';

class NoNavigationbar extends StatelessWidget implements PreferredSizeWidget {
  final String title; //文字标题
  final Widget? titleWidget; //自定义标题
  final bool needBack;
  final Widget? leadingWidget; //自定义标题
  final Widget? bottomWidget;
  final double bottomHeight;
  final double? elevation;
  final List<Widget>? actionWidgets;
  final GestureTapCallback? onLeadingTap;
  final Widget? flexibleSpace;
  final Color? backgroundColor;
  final bool useDefaultBackImage;
  final NineThemeMode mode;

  const NoNavigationbar({
    super.key,
    this.onLeadingTap,
    this.needBack = true,
    this.leadingWidget,
    this.title = "",
    this.titleWidget,
    this.bottomWidget,
    this.actionWidgets,
    this.elevation,
    this.bottomHeight = 0,
    this.useDefaultBackImage = true,
    this.flexibleSpace,
    this.backgroundColor,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      systemOverlayStyle:
          mode == NineThemeMode.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
      title:
          titleWidget ??
          (title.isNotEmpty
              ? Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      mode == NineThemeMode.dark
                          ? Colors.white
                          : appColor.bigTitle,
                ),
              )
              : null),
      flexibleSpace:
          flexibleSpace ??
          (useDefaultBackImage
              ? SizedBox.expand(
                child: Image.asset(
                  appAssets.cartoonAppbarBg,
                  fit: BoxFit.cover,
                ),
              )
              : null),
      leading:
          leadingWidget != null
              ? GestureDetector(
                onTap:
                    onLeadingTap ??
                    () {
                      Get.back();
                    },
                child: leadingWidget,
              )
              : ((needBack
                  ? GestureDetector(
                    onTap:
                        onLeadingTap ??
                        () {
                          Get.back();
                        },
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back,
                        size: 24.sp,
                        color:
                            mode == NineThemeMode.dark
                                ? Colors.white
                                : appColor.bigTitle,
                      ),
                    ),
                  )
                  : null)),
      actions: actionWidgets,

      bottom:
          bottomWidget != null
              ? PreferredSize(
                preferredSize: Size.fromHeight(bottomHeight),
                child: bottomWidget!,
              )
              : null,
      backgroundColor: backgroundColor ?? Colors.transparent,
    );
  }

  @override
  Size get preferredSize {
    if (bottomWidget != null && bottomHeight == 0) {
      return Size.fromHeight(kToolbarHeight + 44);
    }
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }
}
