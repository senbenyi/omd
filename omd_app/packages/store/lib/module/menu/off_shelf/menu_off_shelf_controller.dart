part of '../store_tab_menu_controller.dart';

extension MenuOffShelfController on StoreTabMenuController {
  Future<void> loadOffShelfItems({required int storeId}) async {
    isLoadingItems.value = true;
    try {
      final response = await MenuApi.listItems(
        storeId: storeId,
        status: 'off_sale',
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
      NLog.e('菜单页加载已下架菜品失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
    } finally {
      isLoadingItems.value = false;
    }
  }
}
