import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/menu/category/menu_category_tab_controller.dart';
import 'package:store/module/menu/category/menu_category_ui.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/store_tab_menu_controller.dart';

/// 分类 Tab 左侧分类栏。
class MenuCategoryLeftTab extends StatelessWidget {
  const MenuCategoryLeftTab({
    super.key,
    required this.shell,
    required this.tab,
    required this.bottomInset,
    required this.onAddCategory,
  });

  final StoreTabMenuController shell;
  final MenuCategoryTabController tab;
  final double bottomInset;
  final VoidCallback onAddCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118.w,
      child: ColoredBox(
        color: MenuCategoryLayout.sidebarBackground,
        child: Column(
          children: [
            Expanded(child: _CategoryList(shell: shell, tab: tab)),
            _AddCategoryBar(
              bottomInset: bottomInset,
              onAddCategory: onAddCategory,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.shell, required this.tab});

  final StoreTabMenuController shell;
  final MenuCategoryTabController tab;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categoryList = tab.categories.toList(growable: false);
      final selectedCategoryId = tab.selectedCategoryId.value;
      final loading = tab.isLoadingSidebar.value && categoryList.isEmpty;

      if (loading) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }

      if (categoryList.isEmpty) {
        return MenuCategoryEmptyState(
          message: StoreMenuI18n.noCategoryHint.tr,
          icon: Icons.category_outlined,
          actionHint: StoreMenuI18n.addCategory.tr,
        );
      }

      final storeId = shell.selectedStoreId.value;
      return ListView(
        padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
        children: [
          for (final category in categoryList)
            MenuCategorySidebarTile(
              title: category.name,
              subtitle: StoreMenuI18n.itemCount.trParams({
                'count': '${category.itemCount}',
              }),
              selected: category.id == selectedCategoryId,
              onTap: () {
                if (storeId == null) return;
                tab.selectCategory(storeId: storeId, categoryId: category.id);
              },
            ),
        ],
      );
    });
  }
}

class _AddCategoryBar extends StatelessWidget {
  const _AddCategoryBar({
    required this.bottomInset,
    required this.onAddCategory,
  });

  final double bottomInset;
  final VoidCallback onAddCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: MenuCategoryLayout.divider)),
      ),
      child: Column(
        children: [
          MenuCategorySidebarActionButton(
            label: StoreMenuI18n.addCategory.tr,
            onTap: onAddCategory,
          ),
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }
}
