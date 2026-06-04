import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/menu/menu_core_widgets.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/store_tab_menu_controller.dart';

/// 分类 Tab 左侧分类栏（分类列表 + 底部「添加分类」）。
class MenuCategoryLeftTab extends StatelessWidget {
  const MenuCategoryLeftTab({
    super.key,
    required this.controller,
    required this.bottomInset,
    required this.onAddCategory,
  });

  final StoreTabMenuController controller;
  final double bottomInset;
  final VoidCallback onAddCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118.w,
      child: ColoredBox(
        color: MenuLayout.sidebarBackground,
        child: Column(
          children: [
            Expanded(child: _CategoryList(controller: controller)),
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
  const _CategoryList({required this.controller});

  final StoreTabMenuController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categoryList = controller.categories.toList(growable: false);
      final selectedCategoryId = controller.selectedCategoryId.value;
      final loading =
          controller.isLoadingSidebar.value && categoryList.isEmpty;

      if (loading) {
        return const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      }

      if (categoryList.isEmpty) {
        return MenuEmptyState(
          message: StoreMenuI18n.noCategoryHint.tr,
          icon: Icons.category_outlined,
          actionHint: StoreMenuI18n.addCategory.tr,
        );
      }

      return ListView(
        padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
        children: [
          for (final category in categoryList)
            MenuSidebarTile(
              title: category.name,
              subtitle: StoreMenuI18n.itemCount.trParams({
                'count': '${category.itemCount}',
              }),
              selected: category.id == selectedCategoryId,
              onTap: () => controller.selectCategory(category.id),
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
        border: Border(top: BorderSide(color: MenuLayout.divider)),
      ),
      child: Column(
        children: [
          MenuSidebarActionButton(
            label: StoreMenuI18n.addCategory.tr,
            onTap: onAddCategory,
          ),
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }
}
