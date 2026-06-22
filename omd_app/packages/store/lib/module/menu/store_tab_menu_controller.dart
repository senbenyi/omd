import 'package:base/log/nine_log.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:get/get.dart';
import 'package:store/module/menu/category/menu_category_tab_controller.dart';
import 'package:store/module/menu/combo/menu_combo_tab_controller.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_models.dart';
import 'package:store/module/menu/off_shelf/menu_off_shelf_tab_controller.dart';
import 'package:store/module/menu/sold_out/menu_sold_out_tab_controller.dart';
import 'package:store/module/store/store_api.dart';
import 'package:store/module/store/store_models.dart';
import 'package:store/module/store/store_tab_store_controller.dart';

/// 菜单页壳：店铺选择与 Tab 切换；各 Tab 数据在独立 Controller 中。
class StoreTabMenuController extends GetxController {
  StoreTabMenuController({this.fixedStoreId}) {
    categoryTab = MenuCategoryTabController();
    comboTab = MenuComboTabController();
    soldOutTab = MenuSoldOutTabController();
    offShelfTab = MenuOffShelfTabController();
  }

  final int? fixedStoreId;

  late final MenuCategoryTabController categoryTab;
  late final MenuComboTabController comboTab;
  late final MenuSoldOutTabController soldOutTab;
  late final MenuOffShelfTabController offShelfTab;

  final stores = RxList<StoreModel>([]);
  final selectedStoreId = RxnInt();
  final selectedKind = MenuSidebarKind.category.obs;
  final isLoadingStores = false.obs;

  bool get isStoreLocked => fixedStoreId != null;

  bool get isComboSelected => selectedKind.value == MenuSidebarKind.combo;
  bool get isOffShelfSelected => selectedKind.value == MenuSidebarKind.offShelf;
  bool get isSoldOutSelected => selectedKind.value == MenuSidebarKind.soldOut;

  StoreModel? get selectedStore {
    final id = selectedStoreId.value;
    if (id == null) return null;
    for (final store in stores) {
      if (store.id == id) return store;
    }
    return null;
  }

  bool get isBootstrapping =>
      isLoadingStores.value ||
      (selectedKind.value == MenuSidebarKind.category &&
          categoryTab.isLoadingSidebar.value) ||
      (selectedKind.value == MenuSidebarKind.combo &&
          comboTab.isLoadingSidebar.value) ||
      (selectedKind.value == MenuSidebarKind.soldOut && soldOutTab.isLoading.value) ||
      (selectedKind.value == MenuSidebarKind.offShelf && offShelfTab.isLoading.value);

  @override
  void onInit() {
    super.onInit();
    if (fixedStoreId != null) {
      bootstrap();
    }
  }

  @override
  void onClose() {
    categoryTab.dispose();
    comboTab.dispose();
    soldOutTab.dispose();
    offShelfTab.dispose();
    super.onClose();
  }

  Future<void> ensureLoaded() async {
    if (fixedStoreId != null) {
      if (stores.isEmpty && !isLoadingStores.value) {
        await bootstrapForStore(fixedStoreId!);
      }
      return;
    }

    if (isLoadingStores.value) return;

    if (stores.isEmpty) {
      await bootstrap();
      return;
    }

    final storeId = selectedStoreId.value;
    if (storeId == null) {
      await bootstrap();
      return;
    }

    await _ensureActiveTab(storeId);
  }

  Future<void> bootstrap() async {
    if (fixedStoreId != null) {
      await bootstrapForStore(fixedStoreId!);
      return;
    }
    await loadStores();
    final storeId = selectedStoreId.value;
    if (storeId != null) {
      await _ensureActiveTab(storeId);
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
      _resetAllTabs();
      await _ensureActiveTab(storeId);
    } catch (e, stack) {
      NLog.e('菜单页加载指定店铺失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
    } finally {
      isLoadingStores.value = false;
    }
  }

  void resetForAuthChange() {
    stores.clear();
    selectedStoreId.value = null;
    _resetAllTabs();
  }

  Future<void> loadStores() async {
    isLoadingStores.value = true;
    try {
      if (Get.isRegistered<StoreTabStoreController>()) {
        final storeController = Get.find<StoreTabStoreController>();
        await storeController.loadStores();
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
        _resetAllTabs();
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
    if (selectedStoreId.value == storeId) {
      await _ensureActiveTab(storeId);
      return;
    }
    selectedStoreId.value = storeId;
    selectedKind.value = MenuSidebarKind.category;
    _resetAllTabs();
    await categoryTab.ensureLoaded(storeId);
  }

  void _resetAllTabs() {
    categoryTab.reset();
    comboTab.reset();
    soldOutTab.reset();
    offShelfTab.reset();
  }

  Future<void> switchMenuTab(MenuSidebarKind kind) async {
    if (selectedKind.value == kind) return;
    selectedKind.value = kind;
    final storeId = selectedStoreId.value;
    if (storeId == null) return;
    await _ensureActiveTab(storeId);
  }

  Future<void> _ensureActiveTab(int storeId) async {
    switch (selectedKind.value) {
      case MenuSidebarKind.category:
        await categoryTab.ensureLoaded(storeId);
      case MenuSidebarKind.combo:
        await comboTab.ensureLoaded(storeId);
      case MenuSidebarKind.soldOut:
        await soldOutTab.ensureLoaded(storeId);
      case MenuSidebarKind.offShelf:
        await offShelfTab.ensureLoaded(storeId);
    }
  }

  Future<void> refreshActiveTab() async {
    final storeId = selectedStoreId.value;
    if (storeId == null) return;

    switch (selectedKind.value) {
      case MenuSidebarKind.category:
        await categoryTab.reload(storeId);
      case MenuSidebarKind.combo:
        await comboTab.reload(storeId);
      case MenuSidebarKind.soldOut:
        await soldOutTab.reload(storeId);
      case MenuSidebarKind.offShelf:
        await offShelfTab.reload(storeId);
    }
  }

  Future<bool> addCategory(String name) async {
    final storeId = selectedStoreId.value;
    if (storeId == null) return false;
    return categoryTab.addCategory(storeId, name);
  }

  Future<bool> addCombo(String name) async {
    final storeId = selectedStoreId.value;
    if (storeId == null) return false;
    return comboTab.addCombo(storeId, name);
  }
}
