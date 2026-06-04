import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_models.dart';
import 'package:store/module/menu/category/menu_categoty_dish_item.dart';
import 'package:store/module/menu/category/menu_category_widgets.dart';
import 'package:store/module/menu/category/memu_category_left_tab.dart';
import 'package:store/module/menu/menu_core_widgets.dart';
import 'package:store/module/menu/store_tab_menu_controller.dart';

/// 分类 Tab：左侧分类栏 + 右侧菜品列表。
class MenuCategorySection extends StatelessWidget {
  const MenuCategorySection({
    super.key,
    required this.controller,
    required this.bottomInset,
    required this.onAddCategory,
    required this.onAddItem,
    required this.onEditItem,
    required this.categoryActionsFor,
  });

  final StoreTabMenuController controller;
  final double bottomInset;
  final VoidCallback onAddCategory;
  final VoidCallback onAddItem;
  final ValueChanged<MenuItemListModel> onEditItem;
  final MenuDishCategoryActions Function(MenuItemListModel item) categoryActionsFor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MenuCategoryLeftTab(
          controller: controller,
          bottomInset: bottomInset,
          onAddCategory: onAddCategory,
        ),
        Container(width: 1, color: MenuLayout.divider),
        Expanded(
          child: MenuCategoryItemPanel(
            controller: controller,
            bottomInset: bottomInset,
            onAddItem: onAddItem,
            onEditItem: onEditItem,
            categoryActionsFor: categoryActionsFor,
          ),
        ),
      ],
    );
  }
}

class MenuCategoryItemPanel extends StatelessWidget {
  const MenuCategoryItemPanel({
    super.key,
    required this.controller,
    required this.bottomInset,
    required this.onAddItem,
    required this.onEditItem,
    required this.categoryActionsFor,
  });

  final StoreTabMenuController controller;
  final double bottomInset;
  final VoidCallback onAddItem;
  final ValueChanged<MenuItemListModel> onEditItem;
  final MenuDishCategoryActions Function(MenuItemListModel item) categoryActionsFor;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final category = controller.selectedCategory;
      final itemList = controller.items.toList(growable: false);
      final loadingItems = controller.isLoadingItems.value;
      final loadingSidebar =
          controller.isLoadingSidebar.value && controller.categories.isEmpty;

      if (loadingSidebar) {
        return const Center(child: CircularProgressIndicator());
      }

      if (category == null) {
        if (controller.categories.isEmpty) {
          return Center(
            child: MenuEmptyState(
              message: StoreMenuI18n.noCategoryHint.tr,
              actionHint: StoreMenuI18n.addCategory.tr,
            ),
          );
        }
        if (controller.isLoadingItems.value || controller.isLoadingSidebar.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return MenuEmptyState(message: StoreMenuI18n.noCategory.tr);
      }

      return ColoredBox(
        color: StoreColors.scaffoldBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MenuPanelHeader(
              title: category.name,
              leadingIcon: Icons.restaurant_menu_outlined,
              subtitle: StoreMenuI18n.itemCount.trParams({
                'count': '${itemList.length}',
              }),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshCurrentPanel,
                color: StoreColors.tabSelected,
                child: _buildItemList(
                  itemList: itemList,
                  loading: loadingItems && itemList.isEmpty,
                  onEditItem: onEditItem,
                  categoryActionsFor: categoryActionsFor,
                ),
              ),
            ),
            MenuAddActionBar(
              label: StoreMenuI18n.addItem.tr,
              onTap: onAddItem,
              bottomInset: bottomInset,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildItemList({
    required List<MenuItemListModel> itemList,
    required bool loading,
    required ValueChanged<MenuItemListModel> onEditItem,
    required MenuDishCategoryActions Function(MenuItemListModel item)
    categoryActionsFor,
  }) {
    if (loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120.h),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (itemList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          MenuEmptyState(
            message: StoreMenuI18n.emptyItems.tr,
            actionHint: StoreMenuI18n.addItem.tr,
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
        return MenuCategoryDishItem(
          name: item.name,
          price: item.price,
          tags: item.tags,
          categoryActions: categoryActionsFor(item),
          onTap: () => onEditItem(item),
        );
      },
    );
  }
}
