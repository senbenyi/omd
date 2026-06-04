import 'package:base/log/nine_log.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:get/get.dart';
import 'package:store/module/menu/menu_api.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_models.dart';
import 'package:store/module/store/store_api.dart';
import 'package:store/module/store/store_models.dart';
import 'package:store/module/store/store_tab_store_controller.dart';

part 'category/menu_category_controller.dart';
part 'combo/menu_combo_controller.dart';
part 'sold_out/menu_sold_out_controller.dart';
part 'off_shelf/menu_off_shelf_controller.dart';

class StoreTabMenuController extends GetxController {
  StoreTabMenuController({this.fixedStoreId});

  /// 非空时锁定为单店菜单（从店铺详情进入）。
  final int? fixedStoreId;

  bool get isStoreLocked => fixedStoreId != null;
  final stores = RxList<StoreModel>([]);
  final categories = RxList<MenuCategoryModel>([]);
  final combos = RxList<MenuComboModel>([]);
  final items = RxList<MenuItemListModel>([]);
  final comboDetail = Rxn<MenuComboDetailModel>();

  final selectedStoreId = RxnInt();
  final selectedCategoryId = RxnInt();
  final selectedComboId = RxnInt();
  final selectedKind = MenuSidebarKind.category.obs;

  final isLoadingStores = false.obs;
  final isLoadingSidebar = false.obs;
  final isLoadingItems = false.obs;
  final isLoadingComboDetail = false.obs;
  final isSavingCategory = false.obs;
  final isSavingCombo = false.obs;

  StoreModel? get selectedStore {
    final id = selectedStoreId.value;
    if (id == null) return null;
    for (final store in stores) {
      if (store.id == id) return store;
    }
    return null;
  }

  MenuCategoryModel? get selectedCategory {
    if (selectedKind.value != MenuSidebarKind.category) return null;
    final id = selectedCategoryId.value;
    if (id == null) return null;
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  MenuComboModel? get selectedCombo {
    if (selectedKind.value != MenuSidebarKind.combo) return null;
    final id = selectedComboId.value;
    if (id == null) return null;
    for (final combo in combos) {
      if (combo.id == id) return combo;
    }
    return null;
  }

  bool get isComboSelected => selectedKind.value == MenuSidebarKind.combo;

  bool get isOffShelfSelected => selectedKind.value == MenuSidebarKind.offShelf;

  bool get isSoldOutSelected => selectedKind.value == MenuSidebarKind.soldOut;

  bool get isBootstrapping =>
      isLoadingStores.value || isLoadingSidebar.value || isLoadingItems.value;

  @override
  void onInit() {
    super.onInit();
    if (fixedStoreId != null) {
      bootstrap();
    }
  }

  /// Tab 菜单页首次展示或数据为空时拉取。
  Future<void> ensureLoaded() async {
    if (fixedStoreId != null) {
      if (stores.isEmpty && !isLoadingStores.value) {
        await bootstrapForStore(fixedStoreId!);
      }
      return;
    }

    if (isLoadingStores.value || isLoadingSidebar.value) return;

    if (stores.isEmpty) {
      await bootstrap();
      return;
    }

    final storeId = selectedStoreId.value;
    if (storeId == null) {
      await bootstrap();
      return;
    }

    if (categories.isEmpty && combos.isEmpty) {
      await loadSidebar(storeId);
    }
  }

  Future<void> bootstrap() async {
    if (fixedStoreId != null) {
      await bootstrapForStore(fixedStoreId!);
      return;
    }
    await loadStores();
    final storeId = selectedStoreId.value;
    if (storeId != null) {
      await loadSidebar(storeId);
    }
  }

  Future<void> bootstrapForStore(int storeId) async {
    isLoadingStores.value = true;
    try {
      StoreModel? store;
      if (Get.isRegistered<StoreTabStoreController>()) {
        final storeController = Get.find<StoreTabStoreController>();
        for (final item in storeController.stores) {
          if (item.id == storeId) {
            store = item;
            break;
          }
        }
      }
      if (store == null) {
        final response = await StoreApi.getStoreDetail(storeId);
        if (!response.isSuccess || response.data == null) {
          showAppToast(
            response.message.isNotEmpty
                ? response.message
                : StoreMenuI18n.loadFailed.tr,
          );
          return;
        }
        store = response.data;
      }

      stores.assignAll([store!]);
      selectedStoreId.value = storeId;
      _clearSidebarSelection();
      items.clear();
      comboDetail.value = null;
      await loadSidebar(storeId);
    } catch (e, stack) {
      NLog.e('菜单页加载指定店铺失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
    } finally {
      isLoadingStores.value = false;
    }
  }

  Future<void> loadStores() async {
    isLoadingStores.value = true;
    try {
      if (Get.isRegistered<StoreTabStoreController>()) {
        final storeController = Get.find<StoreTabStoreController>();
        if (storeController.stores.isEmpty) {
          await storeController.loadStores();
        }
        stores
          ..clear()
          ..addAll(storeController.stores.toList());
      } else {
        final response = await StoreApi.listStores();
        if (!response.isSuccess) {
          showAppToast(
            response.message.isNotEmpty
                ? response.message
                : StoreMenuI18n.loadFailed.tr,
          );
          return;
        }
        stores.assignAll(response.data ?? []);
      }

      if (stores.isEmpty) {
        selectedStoreId.value = null;
        _clearSidebarSelection();
        categories.clear();
        combos.clear();
        items.clear();
        comboDetail.value = null;
        return;
      }

      final current = selectedStoreId.value;
      if (current == null || !stores.any((s) => s.id == current)) {
        await selectStore(stores.first.id);
      }
    } catch (e, stack) {
      NLog.e('菜单页加载店铺失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
    } finally {
      isLoadingStores.value = false;
    }
  }

  Future<void> selectStore(int storeId) async {
    if (isStoreLocked && storeId != fixedStoreId) return;
    if (selectedStoreId.value == storeId &&
        (categories.isNotEmpty || combos.isNotEmpty)) {
      return;
    }
    selectedStoreId.value = storeId;
    _clearSidebarSelection();
    items.clear();
    comboDetail.value = null;
    await loadSidebar(storeId);
  }

  void _clearSidebarSelection() {
    selectedCategoryId.value = null;
    selectedComboId.value = null;
    selectedKind.value = MenuSidebarKind.category;
    comboDetail.value = null;
  }

  Future<void> loadSidebar(int storeId) async {
    isLoadingSidebar.value = true;
    try {
      final categoryResponse = await MenuApi.listCategories(storeId);
      final comboResponse = await MenuApi.listCombos(storeId);

      if (!categoryResponse.isSuccess) {
        showAppToast(
          categoryResponse.message.isNotEmpty
              ? categoryResponse.message
              : StoreMenuI18n.loadFailed.tr,
        );
        return;
      }
      if (!comboResponse.isSuccess) {
        showAppToast(
          comboResponse.message.isNotEmpty
              ? comboResponse.message
              : StoreMenuI18n.loadFailed.tr,
        );
        return;
      }

      final categoryList = categoryResponse.data ?? [];
      final comboList = comboResponse.data ?? [];
      categories
        ..clear()
        ..addAll(categoryList);
      categories.refresh();
      combos
        ..clear()
        ..addAll(comboList);
      combos.refresh();

      if (categoryList.isEmpty && comboList.isEmpty) {
        _clearSidebarSelection();
        items.clear();
        return;
      }

      if (selectedKind.value == MenuSidebarKind.category) {
        final currentCategory = selectedCategoryId.value;
        if (currentCategory != null &&
            categoryList.any((c) => c.id == currentCategory)) {
          await loadCategoryItems(storeId: storeId, categoryId: currentCategory);
          return;
        }
      }

      if (selectedKind.value == MenuSidebarKind.offShelf) {
        await loadOffShelfItems(storeId: storeId);
        return;
      }

      if (selectedKind.value == MenuSidebarKind.soldOut) {
        await loadSoldOutItems(storeId: storeId);
        return;
      }

      if (selectedKind.value == MenuSidebarKind.combo) {
        final currentCombo = selectedComboId.value;
        if (currentCombo != null && comboList.any((c) => c.id == currentCombo)) {
          await loadComboDetail(storeId: storeId, comboId: currentCombo);
          return;
        }
      }

      if (categoryList.isNotEmpty) {
        selectedKind.value = MenuSidebarKind.category;
        await selectCategory(categoryList.first.id);
      } else if (comboList.isNotEmpty) {
        selectedKind.value = MenuSidebarKind.combo;
        await selectCombo(comboList.first.id);
      }
    } catch (e, stack) {
      NLog.e('菜单页加载分类/套餐失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
    } finally {
      isLoadingSidebar.value = false;
    }
  }

  Future<void> switchMenuTab(MenuSidebarKind kind) async {
    if (selectedKind.value == kind) return;
    selectedKind.value = kind;
    final storeId = selectedStoreId.value;
    if (storeId == null) return;

    if (kind == MenuSidebarKind.category) {
      final categoryId = selectedCategoryId.value;
      if (categoryId != null && categories.any((c) => c.id == categoryId)) {
        await loadCategoryItems(storeId: storeId, categoryId: categoryId);
        return;
      }
      if (categories.isNotEmpty) {
        await selectCategory(categories.first.id);
        return;
      }
      selectedCategoryId.value = null;
      items.clear();
      items.refresh();
      return;
    }

    if (kind == MenuSidebarKind.offShelf) {
      selectedCategoryId.value = null;
      selectedComboId.value = null;
      comboDetail.value = null;
      await loadOffShelfItems(storeId: storeId);
      return;
    }

    if (kind == MenuSidebarKind.soldOut) {
      selectedCategoryId.value = null;
      selectedComboId.value = null;
      comboDetail.value = null;
      await loadSoldOutItems(storeId: storeId);
      return;
    }

    final comboId = selectedComboId.value;
    if (comboId != null && combos.any((c) => c.id == comboId)) {
      await loadComboDetail(storeId: storeId, comboId: comboId);
      return;
    }
    if (combos.isNotEmpty) {
      await selectCombo(combos.first.id);
      return;
    }
    selectedComboId.value = null;
    comboDetail.value = null;
  }

  Future<bool> updateItemStatus({
    required int itemId,
    required String status,
  }) async {
    final storeId = selectedStoreId.value;
    if (storeId == null) return false;

    try {
      final response = await MenuApi.updateItemStatus(
        storeId,
        UpdateMenuItemStatusRequest(itemId: itemId, status: status),
      );
      if (!response.isSuccess) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreMenuI18n.loadFailed.tr,
        );
        return false;
      }

      showAppToast(StoreMenuI18n.saveSuccess.tr);
      await _refreshSidebarMeta(storeId);
      await refreshCurrentPanel();
      return true;
    } catch (e, stack) {
      NLog.e('菜单页更新菜品状态失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
      return false;
    }
  }

  Future<bool> updateItemSoldOut({
    required int itemId,
    required bool soldOut,
  }) async {
    final storeId = selectedStoreId.value;
    if (storeId == null) return false;

    try {
      final response = await MenuApi.updateItemSoldOut(
        storeId,
        UpdateMenuItemSoldOutRequest(itemId: itemId, soldOut: soldOut),
      );
      if (!response.isSuccess) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreMenuI18n.loadFailed.tr,
        );
        return false;
      }

      showAppToast(StoreMenuI18n.saveSuccess.tr);
      await _refreshSidebarMeta(storeId);
      await refreshCurrentPanel();
      return true;
    } catch (e, stack) {
      NLog.e('菜单页更新售罄状态失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
      return false;
    }
  }

  Future<void> refreshCurrent() async {
    final storeId = selectedStoreId.value;
    if (storeId == null) {
      await loadStores();
      return;
    }
    await loadSidebar(storeId);
  }

  /// 仅刷新右侧当前面板，并同步侧栏计数。
  Future<void> refreshCurrentPanel() async {
    final storeId = selectedStoreId.value;
    if (storeId == null) return;

    await _refreshSidebarMeta(storeId);

    if (isComboSelected) {
      final comboId = selectedComboId.value;
      if (comboId != null) {
        await loadComboDetail(storeId: storeId, comboId: comboId);
      }
      return;
    }

    if (isOffShelfSelected) {
      await loadOffShelfItems(storeId: storeId);
      return;
    }

    if (isSoldOutSelected) {
      await loadSoldOutItems(storeId: storeId);
      return;
    }

    final categoryId = selectedCategoryId.value;
    if (categoryId != null) {
      await loadCategoryItems(storeId: storeId, categoryId: categoryId);
    }
  }

  Future<void> _refreshSidebarMeta(int storeId) async {
    try {
      final categoryResponse = await MenuApi.listCategories(storeId);
      final comboResponse = await MenuApi.listCombos(storeId);
      if (categoryResponse.isSuccess) {
        categories.assignAll(categoryResponse.data ?? []);
      }
      if (comboResponse.isSuccess) {
        combos.assignAll(comboResponse.data ?? []);
      }
    } catch (e, stack) {
      NLog.e('菜单页刷新侧栏计数失败: $e\n$stack');
    }
  }

}
