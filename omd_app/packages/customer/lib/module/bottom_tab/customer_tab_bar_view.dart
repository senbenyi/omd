import 'package:common/commonui/bottom_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:customer/module/a_color/customer_colors.dart';
import 'package:customer/module/bottom_tab/customer_bottom_nav_logic.dart';
import 'package:customer/module/bottom_tab/customer_bottom_tab_config.dart';

class CustomerTabBarView extends GetView<CustomerBottomNavLogic> {
  const CustomerTabBarView({super.key});

  @override
  Widget build(BuildContext context) {
    final barHeight = BottomArea.bottomBarHeigtOf(context);
    return Obx(() {
      return Container(
        height: barHeight,
        decoration: const BoxDecoration(
          color: CustomerColors.tabBarBackground,
          border: Border(top: BorderSide(color: CustomerColors.tabBarBorder)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: List.generate(controller.configList.length, (index) {
              final config = controller.configList[index];
              final isActive = controller.selectedIndex.value == index;
              return Expanded(
                child: _CustomerTabItem(
                  config: config,
                  isActive: isActive,
                  onTap: () => controller.changeIndex(index),
                ),
              );
            }),
          ),
        ),
      );
    });
  }
}

class _CustomerTabItem extends StatelessWidget {
  const _CustomerTabItem({
    required this.config,
    required this.isActive,
    required this.onTap,
  });

  final CustomerTabConfig config;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? CustomerColors.tabSelected : CustomerColors.tabUnselected;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? config.activeIcon : config.icon,
              size: 24.sp,
              color: color,
            ),
            SizedBox(height: 2.h),
            Text(
              config.labelKey.tr,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.2,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
