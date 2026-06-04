import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/combo/menu_combo_tab_controller.dart';
import 'package:store/module/menu/combo/menu_combo_ui.dart';
import 'package:store/module/menu/combo/menu_combo_widgets.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_models.dart';
import 'package:store/module/menu/store_tab_menu_controller.dart';

/// 套餐 Tab：左侧套餐栏 + 右侧套餐详情。
class MenuComboSection extends StatelessWidget {
  const MenuComboSection({
    super.key,
    required this.shell,
    required this.tab,
    required this.bottomInset,
    required this.onAddCombo,
    required this.onConfigureCombo,
  });

  final StoreTabMenuController shell;
  final MenuComboTabController tab;
  final double bottomInset;
  final VoidCallback onAddCombo;
  final VoidCallback onConfigureCombo;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MenuComboLeftTab(
          shell: shell,
          tab: tab,
          bottomInset: bottomInset,
          onAddCombo: onAddCombo,
        ),
        Container(width: 1, color: MenuComboLayout.divider),
        Expanded(
          child: MenuComboDetailPanel(
            shell: shell,
            tab: tab,
            bottomInset: bottomInset,
            onConfigureCombo: onConfigureCombo,
          ),
        ),
      ],
    );
  }
}

class MenuComboLeftTab extends StatelessWidget {
  const MenuComboLeftTab({
    super.key,
    required this.shell,
    required this.tab,
    required this.bottomInset,
    required this.onAddCombo,
  });

  final StoreTabMenuController shell;
  final MenuComboTabController tab;
  final double bottomInset;
  final VoidCallback onAddCombo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118.w,
      child: ColoredBox(
        color: MenuComboLayout.sidebarBackground,
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final comboList = tab.combos.toList(growable: false);
                final selectedComboId = tab.selectedComboId.value;
                final loading =
                    tab.isLoadingSidebar.value && comboList.isEmpty;

                if (loading) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                if (comboList.isEmpty) {
                  return MenuComboEmptyState(
                    message: StoreMenuI18n.emptyComboItems.tr,
                    icon: Icons.layers_outlined,
                    actionHint: StoreMenuI18n.addCombo.tr,
                  );
                }

                final storeId = shell.selectedStoreId.value;
                return ListView(
                  padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                  children: [
                    for (final combo in comboList)
                      MenuComboSidebarTile(
                        title: combo.name,
                        subtitle:
                            combo.itemCount > 0
                                ? StoreMenuI18n.itemCount.trParams({
                                  'count': '${combo.itemCount}',
                                })
                                : null,
                        selected: combo.id == selectedComboId,
                        onTap: () {
                          if (storeId == null) return;
                          tab.selectCombo(storeId: storeId, comboId: combo.id);
                        },
                      ),
                  ],
                );
              }),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: MenuComboLayout.divider)),
              ),
              child: Column(
                children: [
                  MenuComboSidebarActionButton(
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

class MenuComboDetailPanel extends StatelessWidget {
  const MenuComboDetailPanel({
    super.key,
    required this.shell,
    required this.tab,
    required this.bottomInset,
    required this.onConfigureCombo,
  });

  final StoreTabMenuController shell;
  final MenuComboTabController tab;
  final double bottomInset;
  final VoidCallback onConfigureCombo;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final combo = tab.selectedCombo;
      final detail = tab.comboDetail.value;
      final itemList = detail?.items ?? const <MenuComboItemModel>[];
      final loadingSidebar =
          tab.isLoadingSidebar.value && tab.combos.isEmpty;
      final loadingDetail =
          tab.isLoadingDetail.value && detail == null;

      if (loadingSidebar) {
        return const Center(child: CircularProgressIndicator());
      }

      if (tab.combos.isEmpty) {
        return ColoredBox(
          color: StoreColors.scaffoldBackground,
          child: Column(
            children: [
              Expanded(
                child: MenuComboEmptyState(
                  message: StoreMenuI18n.emptyComboItems.tr,
                  icon: Icons.layers_outlined,
                ),
              ),
              MenuComboAddActionBar(
                label: StoreMenuI18n.addCombo.tr,
                onTap: onConfigureCombo,
                bottomInset: bottomInset,
              ),
            ],
          ),
        );
      }

      if (combo == null) {
        if (tab.isLoadingDetail.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return MenuComboEmptyState(
          message: StoreMenuI18n.emptyComboItems.tr,
          icon: Icons.layers_outlined,
        );
      }

      if (loadingDetail) {
        return const Center(child: CircularProgressIndicator());
      }

      final comboPrice = detail?.price ?? combo.price;
      final itemsTotal = tab.comboItemsTotalCents(detail);

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
                onRefresh: () async {
                  final storeId = shell.selectedStoreId.value;
                  if (storeId != null) await tab.reload(storeId);
                },
                color: StoreColors.tabSelected,
                child: _buildComboItemList(
                  itemList: itemList,
                  loading: tab.isLoadingDetail.value && itemList.isEmpty,
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
          MenuComboEmptyState(
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
