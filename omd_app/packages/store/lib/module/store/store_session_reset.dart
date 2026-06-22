import 'package:get/get.dart';
import 'package:store/module/menu/store_tab_menu_controller.dart';
import 'package:store/module/store/store_tab_store_controller.dart';

/// 登录 / 登出时重置店铺相关内存态，避免沿用上一位用户的店铺与选中 Id。
abstract final class StoreSessionReset {
  static void onLogout() {
    if (Get.isRegistered<StoreTabMenuController>()) {
      Get.find<StoreTabMenuController>().resetForAuthChange();
    }
    if (Get.isRegistered<StoreTabStoreController>()) {
      Get.find<StoreTabStoreController>().stores.clear();
    }
  }
}
