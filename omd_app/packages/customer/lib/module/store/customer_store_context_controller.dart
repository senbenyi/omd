import 'package:base/toast/nine_progress_hud.dart';
import 'package:customer/common/customer_constants.dart';
import 'package:customer/module/api/customer_store_api.dart';
import 'package:customer/module/menu/customer_menu_browse_controller.dart';
import 'package:customer/module/order/customer_cart_controller.dart';
import 'package:customer/module/store/customer_store_models.dart';
import 'package:customer/module/store/customer_store_prefs.dart';
import 'package:get/get.dart';

/// 当前选中的点餐门店（全局单例）。
class CustomerStoreContextController extends GetxController {
  static CustomerStoreContextController get to =>
      Get.find<CustomerStoreContextController>();

  final storeId = CustomerConstants.defaultStoreId.obs;
  final storeName = CustomerConstants.defaultStoreName.obs;
  final storeOpen = true.obs;

  @override
  void onInit() {
    super.onInit();
    CustomerStorePrefs.restore(
      setStoreId: (id) => storeId.value = id,
      setStoreName: (name) => storeName.value = name,
      setStoreOpen: (open) => storeOpen.value = open,
    );
    refreshStoreFromApi();
  }

  Future<void> refreshStoreFromApi() async {
    final response = await CustomerStoreApi.listStores();
    if (!response.isSuccess || response.data == null) return;

    final id = storeId.value;
    CustomerStoreModel? match;
    for (final store in response.data!) {
      if (store.id == id) {
        match = store;
        break;
      }
    }
    if (match == null) {
      storeOpen.value = true;
      return;
    }

    storeName.value = match.name;
    storeOpen.value = match.isOpen;
    await CustomerStorePrefs.save(match);
  }

  Future<void> switchStore(CustomerStoreModel store) async {
    if (store.id == storeId.value) return;

    storeId.value = store.id;
    storeName.value = store.name;
    storeOpen.value = store.isOpen;
    await CustomerStorePrefs.save(store);

    CustomerCartController.to.ensureStore(store.id);

    if (!Get.isRegistered<CustomerMenuBrowseController>()) return;

    NineProgressHud.showLoading();
    try {
      await CustomerMenuBrowseController.to.reloadForStore();
    } finally {
      NineProgressHud.dismiss();
    }
  }
}
