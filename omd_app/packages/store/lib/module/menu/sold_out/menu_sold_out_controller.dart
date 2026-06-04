part of '../store_tab_menu_controller.dart';

extension MenuSoldOutController on StoreTabMenuController {
  Future<void> loadSoldOutItems({required int storeId}) async {
    isLoadingItems.value = true;
    try {
      final response = await MenuApi.listItems(
        storeId: storeId,
        soldOut: true,
        pageSize: 200,
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
      NLog.e('菜单页加载已售罄菜品失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
    } finally {
      isLoadingItems.value = false;
    }
  }
}
