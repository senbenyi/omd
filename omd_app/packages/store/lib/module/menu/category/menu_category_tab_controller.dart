import 'package:base/log/nine_log.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:get/get.dart';
import 'package:store/module/menu/menu_api.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_models.dart';

/// 分类 Tab 独立状态与接口（不与其他 Tab 共享列表/选中态）。
class MenuCategoryTabController extends GetxController {
  final categories = RxList<MenuCategoryModel>([]);
  final items = RxList<MenuItemListModel>([]);
  final selectedCategoryId = RxnInt();

  final isLoadingSidebar = false.obs;
  final isLoadingItems = false.obs;
  final isSavingCategory = false.obs;

  int? _boundStoreId;

  MenuCategoryModel? get selectedCategory {
    final id = selectedCategoryId.value;
    if (id == null) return null;
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  void reset() {
    categories.clear();
    items.clear();
    selectedCategoryId.value = null;
    isLoadingSidebar.value = false;
    isLoadingItems.value = false;
  }

  Future<void> ensureLoaded(int storeId) async {
    if (_boundStoreId != storeId) {
      _boundStoreId = storeId;
      reset();
    }
    if (categories.isEmpty && !isLoadingSidebar.value) {
      await loadCategories(storeId);
    } else if (selectedCategoryId.value != null) {
      await loadCategoryItems(
        storeId: storeId,
        categoryId: selectedCategoryId.value!,
      );
    }
  }

  Future<void> loadCategories(int storeId) async {
    isLoadingSidebar.value = true;
    try {
      final response = await MenuApi.listCategories(storeId);
      if (!response.isSuccess) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreMenuI18n.loadFailed.tr,
        );
        return;
      }

      final list = response.data ?? [];
      categories.assignAll(list);

      if (list.isEmpty) {
        selectedCategoryId.value = null;
        items.clear();
        return;
      }

      final current = selectedCategoryId.value;
      if (current != null && list.any((c) => c.id == current)) {
        await loadCategoryItems(storeId: storeId, categoryId: current);
        return;
      }
      await selectCategory(storeId: storeId, categoryId: list.first.id);
    } catch (e, stack) {
      NLog.e('分类 Tab 加载分类失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
    } finally {
      isLoadingSidebar.value = false;
    }
  }

  Future<void> selectCategory({
    required int storeId,
    required int categoryId,
  }) async {
    selectedCategoryId.value = categoryId;
    await loadCategoryItems(storeId: storeId, categoryId: categoryId);
  }

  Future<void> loadCategoryItems({
    required int storeId,
    required int categoryId,
  }) async {
    isLoadingItems.value = true;
    try {
      final response = await MenuApi.listItems(
        storeId: storeId,
        categoryId: categoryId,
        status: 'on_sale',
      );
      if (!response.isSuccess) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreMenuI18n.loadFailed.tr,
        );
        return;
      }

      items.assignAll(response.data?.list ?? []);
    } catch (e, stack) {
      NLog.e('分类 Tab 加载菜品失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
    } finally {
      isLoadingItems.value = false;
    }
  }

  Future<void> reload(int storeId) async {
    await loadCategories(storeId);
  }

  Future<bool> addCategory(int storeId, String name) async {
    isSavingCategory.value = true;
    try {
      final response = await MenuApi.saveCategory(
        storeId,
        SaveMenuCategoryRequest(name: name),
      );
      if (!response.isSuccess || response.data == null) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreMenuI18n.loadFailed.tr,
        );
        return false;
      }

      showAppToast(StoreMenuI18n.saveSuccess.tr);
      await loadCategories(storeId);
      await selectCategory(storeId: storeId, categoryId: response.data!.id);
      return true;
    } finally {
      isSavingCategory.value = false;
    }
  }

  Future<bool> updateItemSoldOut({
    required int storeId,
    required int itemId,
    required bool soldOut,
  }) async {
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
      await reload(storeId);
      return true;
    } catch (e, stack) {
      NLog.e('分类 Tab 更新售罄失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
      return false;
    }
  }

  Future<bool> updateItemStatus({
    required int storeId,
    required int itemId,
    required String status,
  }) async {
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
      await reload(storeId);
      return true;
    } catch (e, stack) {
      NLog.e('分类 Tab 更新菜品状态失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
      return false;
    }
  }
}
