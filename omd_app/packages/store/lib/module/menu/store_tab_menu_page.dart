import 'package:base/toast/nine_progress_hud.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/common/store_translations.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/category/menu_category_panel.dart';
import 'package:store/module/menu/combo/menu_combo_panel.dart';
import 'package:store/module/menu/menu_combo_form_page.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_item_form_page.dart';
import 'package:store/module/menu/menu_models.dart';
import 'package:store/module/menu/menu_widgets.dart';
import 'package:store/module/menu/off_shelf/menu_off_shelf_panel.dart';
import 'package:store/module/menu/sold_out/menu_sold_out_panel.dart';
import 'package:store/module/menu/store_tab_menu_controller.dart';
import 'package:store/module/bottom_tab/store_bottom_nav_logic.dart';
import 'package:store/module/store/store_models.dart';

class StoreTabMenuPage extends GetView<StoreTabMenuController> {
  const StoreTabMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MenuPageBody(showTabHeader: true);
  }
}

/// 菜单页主体，Tab 与 push 单店页共用。
class MenuPageBody extends StatefulWidget {
  const MenuPageBody({
    super.key,
    this.controllerTag,
    this.showTabHeader = true,
  });

  final String? controllerTag;
  final bool showTabHeader;

  @override
  State<MenuPageBody> createState() => _MenuPageBodyState();
}

class _MenuPageBodyState extends State<MenuPageBody>
    with AutomaticKeepAliveClientMixin {
  static const _menuTabIndex = 1;

  StoreTabMenuController get controller {
    if (widget.controllerTag != null) {
      return Get.find<StoreTabMenuController>(tag: widget.controllerTag);
    }
    return Get.find<StoreTabMenuController>();
  }

  bool get _hasTabBar => widget.showTabHeader;

  Worker? _tabIndexWorker;

  double _bottomInset(BuildContext context) =>
      MenuLayout.bottomInset(context, hasTabBar: _hasTabBar);

  @override
  bool get wantKeepAlive => widget.controllerTag == null;

  @override
  void initState() {
    super.initState();
    if (widget.showTabHeader && Get.isRegistered<StoreBottomNavLogic>()) {
      final nav = Get.find<StoreBottomNavLogic>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (nav.selectedIndex.value == _menuTabIndex) {
          controller.ensureLoaded();
        }
      });
      _tabIndexWorker = ever(nav.selectedIndex, (index) {
        if (index == _menuTabIndex) {
          controller.ensureLoaded();
        }
      });
    }
  }

  @override
  void dispose() {
    _tabIndexWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ColoredBox(
      color: StoreColors.scaffoldBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showTabHeader)
              MenuPageHeader(
                title: StoreCommonI18n.tabMenu.tr,
                storeSelector: Obx(() => _buildStoreSelector()),
              ),
            Expanded(child: Obx(() => _buildBody(context))),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreSelector() {
    if (controller.isStoreLocked) {
      final store = controller.selectedStore;
      if (store == null) return const SizedBox.shrink();
      return MenuStoreSelectorChip(label: store.name);
    }

    final storeList = controller.stores.toList(growable: false);
    if (storeList.isEmpty) {
      return const SizedBox.shrink();
    }

    final label =
        controller.selectedStore?.name ??
        storeList.first.name;

    if (storeList.length == 1) {
      return MenuStoreSelectorChip(label: label);
    }

    return MenuStoreSelectorChip(
      label: label,
      showDropdown: true,
      onTap: () => _showStorePicker(storeList),
    );
  }

  Future<void> _showStorePicker(List<StoreModel> storeList) async {
    final selectedId = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                child: Text(
                  StoreMenuI18n.selectStore.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: StoreColors.primaryText,
                  ),
                ),
              ),
              for (final store in storeList)
                ListTile(
                  title: Text(
                    store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing:
                      store.id == controller.selectedStoreId.value
                          ? Icon(
                            Icons.check_rounded,
                            color: StoreColors.tabSelected,
                          )
                          : null,
                  onTap: () => Navigator.pop(sheetContext, store.id),
                ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );

    if (selectedId != null) {
      await controller.selectStore(selectedId);
    }
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoadingStores.value && controller.stores.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.stores.isEmpty) {
      if (controller.isBootstrapping) {
        return const Center(child: CircularProgressIndicator());
      }
      return MenuEmptyState(
        message: StoreMenuI18n.noStore.tr,
        icon: Icons.store_outlined,
      );
    }

    return Container(
      margin: EdgeInsets.only(top: widget.showTabHeader ? 0 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        boxShadow: const [
          BoxShadow(
            color: MenuLayout.cardShadow,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => MenuMainTabBar(
              selected: controller.selectedKind.value,
              onChanged: controller.switchMenuTab,
            ),
          ),
          const Divider(height: 1, color: MenuLayout.divider),
          Expanded(
            child: Obx(() {
              if (controller.isSoldOutSelected) {
                return MenuSoldOutPanel(
                  controller: controller,
                  bottomInset: _bottomInset(context),
                  onEditItem: _openEditItem,
                  onRestoreStock: _onRestoreStockItem,
                );
              }
              if (controller.isOffShelfSelected) {
                return MenuOffShelfPanel(
                  controller: controller,
                  bottomInset: _bottomInset(context),
                  onEditItem: _openEditItem,
                  onRelistItem: _onRelistItem,
                );
              }
              if (controller.isComboSelected) {
                return MenuComboSection(
                  controller: controller,
                  bottomInset: _bottomInset(context),
                  onAddCombo: _showAddComboDialog,
                  onConfigureCombo: _openComboForm,
                );
              }
              return MenuCategorySection(
                controller: controller,
                bottomInset: _bottomInset(context),
                onAddCategory: _showAddCategoryDialog,
                onAddItem: _openAddItem,
                onEditItem: _openEditItem,
                categoryActionsFor: _categoryActionsFor,
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddCategoryDialog() async {
    if (controller.selectedStoreId.value == null) return;

    final name = await showMenuNameInputDialog(
      context: context,
      title: StoreMenuI18n.addCategory.tr,
      hint: StoreMenuI18n.categoryNameHint.tr,
      cancelLabel: StoreMenuI18n.cancel.tr,
      confirmLabel: StoreMenuI18n.confirm.tr,
    );
    if (name == null || name.isEmpty) {
      if (name != null) showAppToast(StoreMenuI18n.formIncomplete.tr);
      return;
    }

    NineProgressHud.showLoading();
    try {
      await controller.addCategory(name);
    } finally {
      NineProgressHud.dismiss();
    }
  }

  Future<void> _showAddComboDialog() async {
    if (controller.selectedStoreId.value == null) return;

    final name = await showMenuNameInputDialog(
      context: context,
      title: StoreMenuI18n.addCombo.tr,
      hint: StoreMenuI18n.comboNameHint.tr,
      cancelLabel: StoreMenuI18n.cancel.tr,
      confirmLabel: StoreMenuI18n.confirm.tr,
    );
    if (name == null || name.isEmpty) {
      if (name != null) showAppToast(StoreMenuI18n.comboNameHint.tr);
      return;
    }

    NineProgressHud.showLoading();
    try {
      await controller.addCombo(name);
    } finally {
      NineProgressHud.dismiss();
    }
  }

  Future<void> _openAddItem() async {
    final storeId = controller.selectedStoreId.value;
    final category = controller.selectedCategory;
    if (storeId == null || category == null) return;

    final created = await Get.to<bool>(
      () => MenuItemFormPage(
        storeId: storeId,
        categoryId: category.id,
        categoryName: category.name,
      ),
    );
    if (created == true) {
      await controller.refreshCurrentPanel();
    }
  }

  Future<void> _openEditItem(MenuItemListModel item) async {
    final storeId = controller.selectedStoreId.value;
    if (storeId == null) return;

    final categoryName =
        item.categoryName.isNotEmpty
            ? item.categoryName
            : controller.selectedCategory?.name ??
                StoreMenuI18n.unknownCategory.tr;

    final saved = await Get.to<bool>(
      () => MenuItemFormPage(
        storeId: storeId,
        categoryId: item.categoryId,
        categoryName: categoryName,
        itemId: item.id,
        itemName: item.name,
      ),
    );
    if (saved == true) {
      await controller.refreshCurrentPanel();
    }
  }

  Future<void> _openComboForm() async {
    final storeId = controller.selectedStoreId.value;
    if (storeId == null) return;

    final combo = controller.selectedCombo;

    final saved = await Get.to<bool>(
      () => MenuComboFormPage(
        storeId: storeId,
        comboId: combo?.id,
        initialDetail: controller.comboDetail.value,
      ),
    );
    if (saved == true) {
      await controller.refreshCurrentPanel();
    }
  }

  Future<bool> _onMarkSoldOutItem(MenuItemListModel item) {
    return controller.updateItemSoldOut(itemId: item.id, soldOut: true);
  }

  Future<bool> _onTakeOffShelfItem(MenuItemListModel item) {
    return controller.updateItemStatus(itemId: item.id, status: 'off_sale');
  }

  Future<void> _onRestoreStockItem(MenuItemListModel item) async {
    await controller.updateItemSoldOut(itemId: item.id, soldOut: false);
  }

  Future<void> _onRelistItem(MenuItemListModel item) async {
    await controller.updateItemStatus(itemId: item.id, status: 'on_sale');
  }

  MenuDishCategoryActions _categoryActionsFor(MenuItemListModel item) {
    return MenuDishCategoryActions(
      soldOut: item.soldOut,
      onMarkSoldOut: () => _onMarkSoldOutItem(item),
      onTakeOffShelf: () => _onTakeOffShelfItem(item),
    );
  }
}
