import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_models.dart';
import 'package:store/module/menu/combo/menu_combo_widgets.dart';
import 'package:store/module/menu/menu_core_widgets.dart';
import 'package:store/module/menu/store_tab_menu_controller.dart';

/// 套餐 Tab：左侧套餐栏 + 右侧套餐详情。
class MenuComboSection extends StatelessWidget {
  const MenuComboSection({
    super.key,
    required this.controller,
    required this.bottomInset,
    required this.onAddCombo,
    required this.onConfigureCombo,
  });

  final StoreTabMenuController controller;
  final double bottomInset;
  final VoidCallback onAddCombo;
  final VoidCallback onConfigureCombo;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MenuComboSidebar(
          controller: controller,
          bottomInset: bottomInset,
          onAddCombo: onAddCombo,
        ),
        Container(width: 1, color: MenuLayout.divider),
        Expanded(
          child: MenuComboPanel(
            controller: controller,
            bottomInset: bottomInset,
            onConfigureCombo: onConfigureCombo,
          ),
        ),
      ],
    );
  }
}

/// 套餐模式左侧栏：仅展示套餐名称列表（无分类层级）。
class MenuComboSidebar extends StatelessWidget {
  const MenuComboSidebar({
    super.key,
    required this.controller,
    required this.bottomInset,
    required this.onAddCombo,
  });

  final StoreTabMenuController controller;
  final double bottomInset;
  final VoidCallback onAddCombo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118.w,
      child: ColoredBox(
        color: MenuLayout.sidebarBackground,
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final comboList = controller.combos.toList(growable: false);
                final selectedComboId = controller.selectedComboId.value;
                final loading =
                    controller.isLoadingSidebar.value && comboList.isEmpty;

                if (loading) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                if (comboList.isEmpty) {
                  return MenuEmptyState(
                    message: StoreMenuI18n.emptyComboItems.tr,
                    icon: Icons.layers_outlined,
                    actionHint: StoreMenuI18n.addCombo.tr,
                  );
                }

                return ListView(
                  padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                  children: [
                    for (final combo in comboList)
                      MenuSidebarTile(
                        title: combo.name,
                        icon: Icons.local_offer_outlined,
                        subtitle:
                            combo.itemCount > 0
                                ? StoreMenuI18n.itemCount.trParams({
                                  'count': '${combo.itemCount}',
                                })
                                : null,
                        selected: combo.id == selectedComboId,
                        onTap: () => controller.selectCombo(combo.id),
                      ),
                  ],
                );
              }),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: MenuLayout.divider)),
              ),
              child: Column(
                children: [
                  MenuSidebarActionButton(
                    label: StoreMenuI18n.addCombo.tr,
                    onTap: onAddCombo,
                    icon: Icons.layers_outlined,
                  ),
                  SizedBox(height: bottomInset),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuComboPanel extends StatelessWidget {
  const MenuComboPanel({
    super.key,
    required this.controller,
    required this.bottomInset,
    required this.onConfigureCombo,
  });

  final StoreTabMenuController controller;
  final double bottomInset;
  final VoidCallback onConfigureCombo;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final combo = controller.selectedCombo;
      final detail = controller.comboDetail.value;
      final itemList = detail?.items ?? const <MenuComboItemModel>[];
      final loadingSidebar =
          controller.isLoadingSidebar.value && controller.combos.isEmpty;
      final loadingDetail =
          controller.isLoadingComboDetail.value && detail == null;

      if (loadingSidebar) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.combos.isEmpty) {
        return ColoredBox(
          color: StoreColors.scaffoldBackground,
          child: Column(
            children: [
              Expanded(
                child: MenuEmptyState(
                  message: StoreMenuI18n.emptyComboItems.tr,
                  icon: Icons.layers_outlined,
                ),
              ),
              MenuAddActionBar(
                label: StoreMenuI18n.addCombo.tr,
                onTap: onConfigureCombo,
                bottomInset: bottomInset,
              ),
            ],
          ),
        );
      }

      if (combo == null) {
        if (controller.isLoadingComboDetail.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return MenuEmptyState(
          message: StoreMenuI18n.emptyComboItems.tr,
          icon: Icons.layers_outlined,
        );
      }

      if (loadingDetail) {
        return const Center(child: CircularProgressIndicator());
      }

      final comboPrice = detail?.price ?? combo.price;
      final itemsTotal = controller.comboItemsTotalCents(detail);

      return ColoredBox(
        color: StoreColors.scaffoldBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MenuComboDetailHeader(
              comboName: combo.name,
              itemsTotalCents: itemsTotal,
              comboPriceCents: comboPrice,
              onEdit: onConfigureCombo,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshCurrentPanel,
                color: StoreColors.tabSelected,
                child: _buildComboItemList(
                  itemList: itemList,
                  loading: controller.isLoadingComboDetail.value && itemList.isEmpty,
                  bottomInset: bottomInset,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildComboItemList({
    required List<MenuComboItemModel> itemList,
    required bool loading,
    double bottomInset = 0,
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
            message: StoreMenuI18n.emptyComboItems.tr,
            icon: Icons.layers_outlined,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 6.h + bottomInset),
      itemCount: itemList.length,
      separatorBuilder: (_, __) => SizedBox(height: 6.h),
      itemBuilder: (context, index) {
        final item = itemList[index];
        return MenuComboDishListTile(
          name: item.name,
          unitPriceCents: item.price,
          qty: item.qty,
          lineTotalCents: item.price * item.qty,
        );
      },
    );
  }
}
