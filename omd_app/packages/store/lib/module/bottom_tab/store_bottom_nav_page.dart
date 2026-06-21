import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/bottom_tab/store_bottom_nav_logic.dart';
import 'package:store/module/bottom_tab/store_tab_bar_view.dart';
import 'package:store/module/order/store_tab_order_page.dart';
import 'package:store/module/menu/store_tab_menu_controller.dart';
import 'package:store/module/menu/store_tab_menu_page.dart';
import 'package:store/module/mine/store_tab_mine_page.dart';
import 'package:store/module/store/store_tab_store_controller.dart';

/// Store 主框架：白色主题 + 3 Tab 底部导航（订单 / 菜单 / 我的）。
class StoreBottomNavPage extends StatefulWidget {
  const StoreBottomNavPage({super.key});

  @override
  State<StoreBottomNavPage> createState() => _StoreBottomNavPageState();
}

class _StoreBottomNavPageState extends State<StoreBottomNavPage> {
  late final StoreBottomNavLogic _logic;
  late final List<Widget> _tabPages;

  @override
  void initState() {
    super.initState();
    _logic = Get.put(StoreBottomNavLogic());
    if (!Get.isRegistered<StoreTabStoreController>()) {
      Get.put(StoreTabStoreController(), permanent: true);
    } else {
      unawaited(Get.find<StoreTabStoreController>().loadStores());
    }
    if (!Get.isRegistered<StoreTabMenuController>()) {
      Get.put(StoreTabMenuController(), permanent: true);
    } else {
      Get.find<StoreTabMenuController>().resetForAuthChange();
    }
    _tabPages = const [
      StoreTabOrderPage(),
      StoreTabMenuPage(),
      StoreTabMinePage(),
    ];
  }

  @override
  void dispose() {
    Get.delete<StoreBottomNavLogic>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: StoreColors.tabBarBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: StoreColors.scaffoldBackground,
        body: Stack(
          children: [
            Obx(() {
              final index = _logic.selectedIndex.value.clamp(
                0,
                _logic.configList.length - 1,
              );
              return IndexedStack(index: index, children: _tabPages);
            }),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: StoreTabBarView(),
            ),
          ],
        ),
      ),
    );
  }
}
