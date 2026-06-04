import 'package:flutter/material.dart';
import 'package:store/module/menu/category/menu_category_widgets.dart';
import 'package:store/module/menu/menu_core_widgets.dart';

class MenuOffShelfDishListTile extends StatelessWidget {
  const MenuOffShelfDishListTile({
    super.key,
    required this.name,
    required this.price,
    required this.categoryName,
    this.tags = const [],
    this.createdAt,
    required this.onSaleLabel,
    required this.offSaleLabel,
    required this.relistLabel,
    required this.onRelist,
    this.onTap,
  });

  final String name;
  final int price;
  final String categoryName;
  final List<String> tags;
  final String? createdAt;
  final String onSaleLabel;
  final String offSaleLabel;
  final String relistLabel;
  final VoidCallback onRelist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MenuDishListTile(
      name: name,
      price: price,
      categoryName: categoryName,
      tags: tags,
      createdAt: createdAt,
      isOnSale: false,
      showStatusBadges: true,
      onSaleLabel: onSaleLabel,
      offSaleLabel: offSaleLabel,
      actions: [
        MenuItemAction(
          label: relistLabel,
          foreground: MenuDishActionColors.onShelfFg,
          background: MenuDishActionColors.onShelfBg,
          borderColor: MenuDishActionColors.onShelfBorder,
          onTap: onRelist,
        ),
      ],
      onTap: onTap,
    );
  }
}
