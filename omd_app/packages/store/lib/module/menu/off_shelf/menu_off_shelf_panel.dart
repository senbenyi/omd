import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_core_widgets.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_models.dart';
import 'package:store/module/menu/off_shelf/menu_off_shelf_widgets.dart';
import 'package:store/module/menu/store_tab_menu_controller.dart';

/// 已下架 Tab：全宽菜品列表。
class MenuOffShelfPanel extends StatelessWidget {
  const MenuOffShelfPanel({
    super.key,
    required this.controller,
    required this.bottomInset,
    required this.onEditItem,
    required this.onRelistItem,
  });

  final StoreTabMenuController controller;
  final double bottomInset;
  final ValueChanged<MenuItemListModel> onEditItem;
  final ValueChanged<MenuItemListModel> onRelistItem;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final itemList = controller.items.toList(growable: false);
      final loading =
          controller.isLoadingItems.value && itemList.isEmpty;

      if (loading) {
        return const Center(child: CircularProgressIndicator());
      }

      return ColoredBox(
        color: StoreColors.scaffoldBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MenuPanelHeader(
              title: StoreMenuI18n.offShelfSectionLabel.tr,
              leadingIcon: Icons.inventory_2_outlined,
              subtitle: StoreMenuI18n.itemCount.trParams({
                'count': '${itemList.length}',
              }),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshCurrentPanel,
                color: StoreColors.tabSelected,
                child: _buildOffShelfList(
                  itemList: itemList,
                  onEditItem: onEditItem,
                  onRelistItem: onRelistItem,
                ),
              ),
            ),
            SizedBox(height: bottomInset),
          ],
        ),
      );
    });
  }

  Widget _buildOffShelfList({
    required List<MenuItemListModel> itemList,
    required ValueChanged<MenuItemListModel> onEditItem,
    required ValueChanged<MenuItemListModel> onRelistItem,
  }) {
    if (itemList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          MenuEmptyState(
            message: StoreMenuI18n.emptyOffShelfItems.tr,
            icon: Icons.inventory_2_outlined,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 6.h),
      itemCount: itemList.length,
      separatorBuilder: (_, __) => SizedBox(height: 6.h),
      itemBuilder: (context, index) {
        final item = itemList[index];
        return MenuOffShelfDishListTile(
          name: item.name,
          price: item.price,
          categoryName: item.categoryName.isNotEmpty
              ? item.categoryName
              : StoreMenuI18n.unknownCategory.tr,
          tags: item.tags,
          createdAt: item.createdAt,
          onSaleLabel: StoreMenuI18n.statusOnSale.tr,
          offSaleLabel: StoreMenuI18n.statusOffSale.tr,
          relistLabel: StoreMenuI18n.relistItem.tr,
          onRelist: () => onRelistItem(item),
          onTap: () => onEditItem(item),
        );
      },
    );
  }
}
