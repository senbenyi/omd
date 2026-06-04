import 'package:base/log/nine_log.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:get/get.dart';
import 'package:store/module/menu/menu_api.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_models.dart';

/// 已下架 Tab 独立状态与接口。
class MenuOffShelfTabController extends GetxController {
  final items = RxList<MenuItemListModel>([]);
  final isLoading = false.obs;

  int? _boundStoreId;

  void reset() {
    items.clear();
    isLoading.value = false;
  }

  Future<void> ensureLoaded(int storeId) async {
    if (_boundStoreId != storeId) {
      _boundStoreId = storeId;
      reset();
    }
    await loadItems(storeId);
  }

  Future<void> loadItems(int storeId) async {
    isLoading.value = true;
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
      items.assignAll(response.data?.list ?? []);
    } catch (e, stack) {
      NLog.e('已下架 Tab 加载失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reload(int storeId) => loadItems(storeId);

  Future<bool> relistItem({
    required int storeId,
    required int itemId,
  }) async {
    try {
      final response = await MenuApi.updateItemStatus(
        storeId,
        UpdateMenuItemStatusRequest(itemId: itemId, status: 'on_sale'),
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
      await loadItems(storeId);
      return true;
    } catch (e, stack) {
      NLog.e('已下架 Tab 上架失败: $e\n$stack');
      showAppToast(StoreMenuI18n.loadFailed.tr);
      return false;
    }
  }
}
