import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_models.dart';
import 'package:store/module/menu/sold_out/menu_sold_out_tab_controller.dart';
import 'package:store/module/menu/sold_out/menu_sold_out_ui.dart';
import 'package:store/module/menu/sold_out/menu_sold_out_widgets.dart';
import 'package:store/module/menu/store_tab_menu_controller.dart';

/// 已售罄 Tab。
class MenuSoldOutPanel extends StatelessWidget {
  const MenuSoldOutPanel({
    super.key,
    required this.shell,
    required this.tab,
    required this.bottomInset,
    required this.onEditItem,
    required this.onRestoreStock,
  });

  final StoreTabMenuController shell;
  final MenuSoldOutTabController tab;
  final double bottomInset;
  final ValueChanged<MenuItemListModel> onEditItem;
  final ValueChanged<MenuItemListModel> onRestoreStock;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final itemList = tab.items.toList(growable: false);
      final loading = tab.isLoading.value && itemList.isEmpty;

      if (loading) {
        return const Center(child: CircularProgressIndicator());
      }

      return ColoredBox(
        color: StoreColors.scaffoldBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MenuSoldOutPanelHeader(
              title: StoreMenuI18n.soldOutSectionLabel.tr,
              leadingIcon: Icons.remove_shopping_cart_outlined,
              subtitle: StoreMenuI18n.itemCount.trParams({
                'count': '${itemList.length}',
              }),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final storeId = shell.selectedStoreId.value;
                  if (storeId != null) await tab.reload(storeId);
                },
                color: StoreColors.tabSelected,
                child: _buildSoldOutList(
                  itemList: itemList,
                  onEditItem: onEditItem,
                  onRestoreStock: onRestoreStock,
                ),
              ),
            ),
            SizedBox(height: bottomInset),
          ],
        ),
      );
    });
  }

  Widget _buildSoldOutList({
    required List<MenuItemListModel> itemList,
    required ValueChanged<MenuItemListModel> onEditItem,
    required ValueChanged<MenuItemListModel> onRestoreStock,
  }) {
    if (itemList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          MenuSoldOutEmptyState(
            message: StoreMenuI18n.emptySoldOutItems.tr,
            icon: Icons.remove_shopping_cart_outlined,
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
        return MenuSoldOutDishListTile(
          name: item.name,
          price: item.price,
          categoryName: item.categoryName.isNotEmpty
              ? item.categoryName
              : StoreMenuI18n.unknownCategory.tr,
          tags: item.tags,
          restoreLabel: StoreMenuI18n.restoreStock.tr,
          onRestoreStock: () => onRestoreStock(item),
          onTap: () => onEditItem(item),
        );
      },
    );
  }
}
