import 'package:flutter/material.dart';
import 'package:store/module/menu/category/menu_category_widgets.dart';
import 'package:store/module/menu/menu_core_widgets.dart';

class MenuSoldOutDishListTile extends StatelessWidget {
  const MenuSoldOutDishListTile({
    super.key,
    required this.name,
    required this.price,
    required this.categoryName,
    this.tags = const [],
    this.createdAt,
    required this.soldOutLabel,
    required this.restoreLabel,
    required this.onRestoreStock,
    this.onTap,
  });

  final String name;
  final int price;
  final String categoryName;
  final List<String> tags;
  final String? createdAt;
  final String soldOutLabel;
  final String restoreLabel;
  final VoidCallback onRestoreStock;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MenuDishListTile(
      name: name,
      price: price,
      categoryName: categoryName,
      tags: tags,
      createdAt: createdAt,
      soldOut: true,
      soldOutLabel: soldOutLabel,
      actions: [
        MenuItemAction(
          label: restoreLabel,
          foreground: MenuDishActionColors.onShelfFg,
          background: MenuDishActionColors.onShelfBg,
          borderColor: MenuDishActionColors.onShelfBorder,
          onTap: onRestoreStock,
        ),
      ],
      onTap: onTap,
    );
  }
}
