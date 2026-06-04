import 'package:flutter/material.dart';
import 'package:customer/common/customer_translations.dart';
import 'package:customer/module/bottom_tab/customer_bottom_tab_type.dart';

class CustomerTabConfig {
  const CustomerTabConfig({
    required this.type,
    required this.labelKey,
    required this.icon,
    required this.activeIcon,
  });

  final CustomerBottomTabType type;
  final String labelKey;
  final IconData icon;
  final IconData activeIcon;
}

abstract final class CustomerBottomTabConfig {
  static const List<CustomerTabConfig> tabs = [
    CustomerTabConfig(
      type: CustomerBottomTabType.home,
      labelKey: CustomerCommonI18n.tabHome,
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    CustomerTabConfig(
      type: CustomerBottomTabType.menu,
      labelKey: CustomerCommonI18n.tabMenu,
      icon: Icons.restaurant_menu_outlined,
      activeIcon: Icons.restaurant_menu_rounded,
    ),
    CustomerTabConfig(
      type: CustomerBottomTabType.mine,
      labelKey: CustomerCommonI18n.tabMine,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];
}
