import 'package:customer/module/menu/customer_menu_browse_controller.dart';
import 'package:customer/module/menu/customer_menu_models.dart';
import 'package:customer/common/customer_translations.dart';
import 'package:customer/module/a_color/customer_colors.dart';
import 'package:customer/module/common/customer_retry_view.dart';
import 'package:customer/module/common/customer_table_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

abstract final class CustomerMenuLayout {
  static const divider = Color(0xFFE4E7EC);
  static const sidebarBackground = Color(0xFFF0F2F6);
}

class CustomerMenuBrowseBody extends StatelessWidget {
  const CustomerMenuBrowseBody({super.key, required this.controller});

  final CustomerMenuBrowseController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => _buildMainContent());
  }

  Widget _buildMainContent() {
    if (controller.isLoading.value &&
        controller.categories.isEmpty &&
        controller.combos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.errorMessage.value.isNotEmpty &&
        controller.categories.isEmpty &&
        controller.combos.isEmpty) {
      return CustomerRetryView(
        message: controller.errorMessage.value,
        onRetry: controller.loadMenu,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CustomerMenuSidebar(controller: controller),
        Container(width: 1, color: CustomerMenuLayout.divider),
        Expanded(child: _CustomerMenuContentPanel(controller: controller)),
      ],
    );
  }
}

class _CustomerMenuSidebar extends StatelessWidget {
  const _CustomerMenuSidebar({required this.controller});

  final CustomerMenuBrowseController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108.w,
      child: ColoredBox(
        color: CustomerMenuLayout.sidebarBackground,
        child: Obx(() {
          final categories = controller.categories.toList(growable: false);
          final selectedId = controller.selectedCategoryId.value;
          final isCombo =
              controller.sidebarKind.value == CustomerMenuSidebarKind.combo;
          final comboCount = controller.combos.length;

          if (categories.isEmpty && comboCount == 0) {
            return Center(
              child: Text(
                CustomerCommonI18n.emptyMenu.tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CustomerColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
            children: [
              for (final category in categories)
                _SidebarTile(
                  title: category.name,
                  subtitle: '${category.itemCount}',
                  selected: !isCombo && category.id == selectedId,
                  onTap: () => controller.selectCategory(category.id),
                ),
              if (comboCount > 0 || categories.isNotEmpty)
                _SidebarTile(
                  title: CustomerCommonI18n.tabCombo.tr,
                  subtitle: '$comboCount',
                  selected: isCombo,
                  onTap: controller.selectComboTab,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      selected
                          ? CustomerColors.tabSelected
                          : CustomerColors.primaryText,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: CustomerColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerMenuContentPanel extends StatelessWidget {
  const _CustomerMenuContentPanel({required this.controller});

  final CustomerMenuBrowseController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.sidebarKind.value == CustomerMenuSidebarKind.combo) {
        return _ComboList(controller: controller);
      }
      return _ItemList(controller: controller);
    });
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({required this.controller});

  final CustomerMenuBrowseController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.visibleItems.toList(growable: false);
      if (items.isEmpty) {
        return Center(
          child: Text(
            CustomerCommonI18n.emptyMenu.tr,
            style: TextStyle(
              color: CustomerColors.secondaryText,
              fontSize: 14.sp,
            ),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadMenu,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder:
              (context, index) => _MenuItemCard(
                item: items[index],
                onAdd: () => controller.addItemToCart(items[index]),
              ),
        ),
      );
    });
  }
}

class _ComboList extends StatelessWidget {
  const _ComboList({required this.controller});

  final CustomerMenuBrowseController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final combos = controller.combos.toList(growable: false);
      if (combos.isEmpty) {
        return Center(
          child: Text(
            CustomerCommonI18n.emptyCombo.tr,
            style: TextStyle(
              color: CustomerColors.secondaryText,
              fontSize: 14.sp,
            ),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadMenu,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
          itemCount: combos.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder:
              (context, index) => _ComboCard(
                combo: combos[index],
                onAdd: () => controller.addComboToCart(combos[index]),
              ),
        ),
      );
    });
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.item, required this.onAdd});

  final CustomerMenuItemModel item;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomerColors.primaryText,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomerPriceText(cents: item.price),
              ],
            ),
          ),
          CustomerQtyStepper(type: 'item', id: item.id, onAdd: onAdd),
        ],
      ),
    );
  }
}

class _ComboCard extends StatelessWidget {
  const _ComboCard({required this.combo, required this.onAdd});

  final CustomerComboModel combo;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  combo.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomerColors.primaryText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${combo.itemCount} 道菜',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CustomerColors.secondaryText,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomerPriceText(cents: combo.price),
              ],
            ),
          ),
          CustomerQtyStepper(type: 'combo', id: combo.id, onAdd: onAdd),
        ],
      ),
    );
  }
}
