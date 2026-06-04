import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:customer/module/a_color/customer_colors.dart';
import 'package:customer/module/bottom_tab/customer_bottom_nav_logic.dart';
import 'package:customer/module/bottom_tab/customer_bottom_tab_type.dart';
import 'package:customer/module/bottom_tab/customer_tab_bar_view.dart';
import 'package:customer/module/home/customer_tab_home_page.dart';
import 'package:customer/module/menu/customer_tab_menu_page.dart';
import 'package:customer/module/mine/customer_tab_mine_page.dart';

/// Customer 主框架：白色主题 + 3 Tab 底部导航（首页 / 菜单 / 我的）。
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
        case CustomerBottomTabType.home:
          return const CustomerTabHomePage();
        case CustomerBottomTabType.menu:
          return const CustomerTabMenuPage();
        case CustomerBottomTabType.mine:
          return const CustomerTabMinePage();
      }
    }).toList();
  }
}
