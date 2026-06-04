import 'package:base/log/nine_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BottomArea {
  static double get bottomBarHeigt {
    return 56.w + Get.mediaQuery.padding.bottom;
  }

  static double safeBottomInsetOf(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    NLog.d('BottomArea safeBottomInset: $bottomInset');
    return bottomInset;
  }

  static double bottomBarHeigtOf(BuildContext context) {
    return kBottomNavigationBarHeight + safeBottomInsetOf(context);
  }
}

class BoottomBarAreaWrap extends StatelessWidget {
  final Widget child;
  const BoottomBarAreaWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: BottomArea.bottomBarHeigt),
      child: child,
    );
  }
}
