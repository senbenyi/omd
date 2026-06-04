import 'package:base/log/nine_log.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:get/get.dart';
import 'package:store/module/store/store_api.dart';
import 'package:store/module/store/store_i18n.dart';
import 'package:store/module/store/store_models.dart';

class StoreTabStoreController extends GetxController {
  final stores = RxList<StoreModel>([]);
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStores();
  }

  Future<void> loadStores() async {
    isLoading.value = true;
    try {
      final response = await StoreApi.listStores();
      if (!response.isSuccess) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreStoreI18n.loadFailed.tr,
        );
        return;
      }

      final list = response.data ?? <StoreModel>[];
      stores
        ..clear()
        ..addAll(list);
      stores.refresh();
      NLog.d('店铺列表加载成功 count=${list.length}');
    } catch (e, stack) {
      NLog.e('店铺列表加载异常: $e\n$stack');
      showAppToast(StoreStoreI18n.loadFailed.tr);
    } finally {
      isLoading.value = false;
    }
  }
}
