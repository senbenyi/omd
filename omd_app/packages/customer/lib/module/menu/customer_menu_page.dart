import 'package:customer/module/common/customer_menu_shell.dart';
import 'package:customer/module/menu/customer_menu_browse_body.dart';
import 'package:customer/module/menu/customer_menu_browse_controller.dart';
import 'package:flutter/material.dart';

/// 顾客端首页：当前店铺菜单。
class CustomerMenuPage extends StatelessWidget {
  const CustomerMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CustomerMenuBrowseController.to;
    return CustomerMenuShell(
      showStoreButton: true,
      showRestHint: true,
      body: CustomerMenuBrowseBody(controller: controller),
    );
  }
}
