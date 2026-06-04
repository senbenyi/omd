part of '../store_tab_menu_controller.dart';

extension MenuCategoryController on StoreTabMenuController {
  Future<void> selectCategory(int categoryId) async {
    selectedKind.value = MenuSidebarKind.category;
    selectedCategoryId.value = categoryId;
    selectedComboId.value = null;
    final storeId = selectedStoreId.value;
    if (storeId == null) return;
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

      items
        ..clear()
        ..addAll(response.data?.list ?? []);
      items.refresh();
    } catch (e, stack) {
      NLog.e('菜单页加载菜品失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
    } finally {
      isLoadingItems.value = false;
    }
  }

  Future<bool> addCategory(String name) async {
    final storeId = selectedStoreId.value;
    if (storeId == null) return false;

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
      await loadSidebar(storeId);
      await selectCategory(response.data!.id);
      return true;
    } finally {
      isSavingCategory.value = false;
    }
  }
}
