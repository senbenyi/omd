import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store/common/user/go_user_controller.dart';
import 'package:store/module/bottom_tab/store_bottom_nav_page.dart';
import 'package:store/module/login/store_login_page.dart';

/// 根据登录态展示登录页或主框架。
class StoreAppRoot extends StatelessWidget {
  const StoreAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final user = GoUserController.to;
    return Obx(() {
      if (user.isLogin.value) {
        return const StoreBottomNavPage();
      }
      return const StoreLoginPage();
    });
  }
}
