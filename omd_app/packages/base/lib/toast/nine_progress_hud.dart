import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base/theme/app_theme.dart';

class NineProgressHud {
  //
  static Future<void> showLoading({String? message, int? timeout}) async {
    init();
    EasyLoading.show();
    if (timeout != null) {
      Future.delayed(Duration(seconds: timeout), () {
        EasyLoading.dismiss();
      });
    }
  }

  static dismiss({bool animation = true}) {
    EasyLoading.dismiss(animation: animation);
  }

  // 初始化Loading样式
  static init() {
    // 根据主题模式判断是黑色还是白色主题
    final isDark = appChannel.isDark;

    // 根据主题设置指示器颜色
    final indicatorColor = isDark ? Colors.white : Colors.black;

    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..maskType = EasyLoadingMaskType.clear
      ..indicatorWidget = SizedBox(
        width: 80.w,
        height: 80.w,
        child: CupertinoActivityIndicator(radius: 20, color: indicatorColor),
      )
      ..backgroundColor =
          Colors
              .transparent // 透明背景，去掉背景框
      ..boxShadow =
          <BoxShadow>[] // 无阴影
      ..indicatorColor = indicatorColor
      ..textColor = indicatorColor
      ..radius =
          0
              .r // 圆角设为0，因为背景透明
      ..contentPadding = EdgeInsets.zero; // 内边距设为0

    return (BuildContext context, Widget? child) {
      return FlutterEasyLoading(child: child);
    };
  }

  //!end class
}
