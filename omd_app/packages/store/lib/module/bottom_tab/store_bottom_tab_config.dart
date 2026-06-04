import 'package:flutter/material.dart';
import 'package:store/common/store_translations.dart';
import 'package:store/module/bottom_tab/store_bottom_tab_type.dart';

class StoreTabConfig {
  const StoreTabConfig({
    required this.type,
    required this.labelKey,
    required this.icon,
    required this.activeIcon,
  });

  final StoreBottomTabType type;
  final String labelKey;
  final IconData icon;
  final IconData activeIcon;
}

abstract final class StoreBottomTabConfig {
  static const List<StoreTabConfig> tabs = [
    StoreTabConfig(
      type: StoreBottomTabType.store,
      labelKey: StoreCommonI18n.tabStore,
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront_rounded,
    ),
    StoreTabConfig(
      type: StoreBottomTabType.menu,
      labelKey: StoreCommonI18n.tabMenu,
      icon: Icons.restaurant_menu_outlined,
      activeIcon: Icons.restaurant_menu_rounded,
    ),
    StoreTabConfig(
      type: StoreBottomTabType.mine,
      labelKey: StoreCommonI18n.tabMine,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];
}
