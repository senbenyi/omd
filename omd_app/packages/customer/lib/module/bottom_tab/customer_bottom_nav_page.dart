import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:customer/module/a_color/customer_colors.dart';
import 'package:customer/module/bottom_tab/customer_bottom_nav_logic.dart';
import 'package:customer/module/bottom_tab/customer_bottom_tab_type.dart';
import 'package:customer/module/bottom_tab/customer_tab_bar_view.dart';
import 'package:customer/module/combo/customer_tab_combo_page.dart';
import 'package:customer/module/menu/customer_tab_menu_page.dart';
import 'package:customer/module/order/customer_tab_order_page.dart';

/// Customer 主框架：3 Tab（菜单 / 套餐 / 订单），无需登录。
class CustomerBottomNavPage extends StatefulWidget {
  const CustomerBottomNavPage({super.key});

  @override
  State<CustomerBottomNavPage> createState() => _CustomerBottomNavPageState();
}

class _CustomerBottomNavPageState extends State<CustomerBottomNavPage> {
  late final CustomerBottomNavLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = Get.put(CustomerBottomNavLogic());
  }

  @override
  void dispose() {
    Get.delete<CustomerBottomNavLogic>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: CustomerColors.tabBarBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: CustomerColors.scaffoldBackground,
        body: Stack(
          children: [
            Obx(() {
              final index = _logic.selectedIndex.value.clamp(
                0,
                _logic.configList.length - 1,
              );
              return IndexedStack(index: index, children: _buildTabPages());
            }),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomerTabBarView(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTabPages() {
    return _logic.configList.map((config) {
      switch (config.type) {
        case CustomerBottomTabType.menu:
          return const CustomerTabMenuPage();
        case CustomerBottomTabType.combo:
          return const CustomerTabComboPage();
        case CustomerBottomTabType.order:
          return const CustomerTabOrderPage();
      }
    }).toList();
  }
}
