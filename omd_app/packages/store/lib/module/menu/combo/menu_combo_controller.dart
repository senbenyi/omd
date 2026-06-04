part of '../store_tab_menu_controller.dart';

extension MenuComboController on StoreTabMenuController {
  /// 套餐内菜品按单价×份数合计（分）。
  int comboItemsTotalCents(MenuComboDetailModel? detail) {
    if (detail == null) return 0;
    var total = 0;
    for (final item in detail.items) {
      total += item.price * item.qty;
    }
    return total;
  }

  Future<void> selectCombo(int comboId) async {
    selectedKind.value = MenuSidebarKind.combo;
    selectedComboId.value = comboId;
    selectedCategoryId.value = null;
    items.clear();
    items.refresh();
    final storeId = selectedStoreId.value;
    if (storeId == null) return;
    await loadComboDetail(storeId: storeId, comboId: comboId);
  }

  Future<void> loadComboDetail({
    required int storeId,
    required int comboId,
  }) async {
    isLoadingComboDetail.value = true;
    try {
      final response = await MenuApi.getComboDetail(storeId, comboId);
      if (!response.isSuccess) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreMenuI18n.loadFailed.tr,
        );
        return;
      }
      comboDetail.value = response.data;
    } catch (e, stack) {
      NLog.e('菜单页加载套餐详情失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
    } finally {
      isLoadingComboDetail.value = false;
    }
  }

  Future<bool> addCombo(String name) async {
    final storeId = selectedStoreId.value;
    if (storeId == null) return false;

    isSavingCombo.value = true;
    try {
      final response = await MenuApi.saveCombo(
        storeId,
        SaveMenuComboRequest(name: name),
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
      await selectCombo(response.data!.id);
      return true;
    } finally {
      isSavingCombo.value = false;
    }
  }
}
