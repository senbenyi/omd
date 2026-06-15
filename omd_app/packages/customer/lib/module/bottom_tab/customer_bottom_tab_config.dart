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
      type: CustomerBottomTabType.menu,
      labelKey: CustomerCommonI18n.tabMenu,
      icon: Icons.restaurant_menu_outlined,
      activeIcon: Icons.restaurant_menu_rounded,
    ),
    CustomerTabConfig(
      type: CustomerBottomTabType.combo,
      labelKey: CustomerCommonI18n.tabCombo,
      icon: Icons.lunch_dining_outlined,
      activeIcon: Icons.lunch_dining_rounded,
    ),
    CustomerTabConfig(
      type: CustomerBottomTabType.order,
      labelKey: CustomerCommonI18n.tabOrder,
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
  ];
}
