import 'package:base/module/base_module.dart';
import 'package:common/http/go_http.dart';
import 'package:common/http/go_http_config.dart';
import 'package:customer/module/menu/customer_menu_browse_controller.dart';
import 'package:customer/module/order/customer_cart_controller.dart';
import 'package:customer/module/order/customer_order_session_controller.dart';
import 'package:customer/module/store/customer_store_context_controller.dart';
import 'package:get/get.dart';

/// Customer 业务模块入口。
class CustomerModule implements BaseModule {
  CustomerModule._();
  static final CustomerModule _instance = CustomerModule._();
  factory CustomerModule() => _instance;
  static CustomerModule get instance => _instance;

  Future<void> init() async {
    await GoHttp.instance.registerHttpServer(GoHttpConfig.instance);
    if (!Get.isRegistered<CustomerCartController>()) {
      Get.put(CustomerCartController(), permanent: true);
    }
    if (!Get.isRegistered<CustomerStoreContextController>()) {
      Get.put(CustomerStoreContextController(), permanent: true);
    }
    if (!Get.isRegistered<CustomerOrderSessionController>()) {
      Get.put(CustomerOrderSessionController(), permanent: true);
    }
    if (!Get.isRegistered<CustomerMenuBrowseController>()) {
      Get.put(CustomerMenuBrowseController(), permanent: true);
    }
  }

  @override
  void initAssets() {}

  @override
  void initColorTheme() {}
}
