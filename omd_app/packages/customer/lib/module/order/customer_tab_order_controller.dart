import 'package:base/toast/nine_progress_hud.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:customer/common/customer_constants.dart';
import 'package:customer/module/api/customer_menu_api.dart';
import 'package:customer/module/bottom_tab/customer_bottom_nav_logic.dart';
import 'package:customer/module/bottom_tab/customer_bottom_tab_type.dart';
import 'package:customer/module/order/customer_cart_controller.dart';
import 'package:get/get.dart';

class CustomerTabOrderController extends GetxController {
  final isSubmitting = false.obs;

  CustomerCartController get cart => CustomerCartController.to;

  Future<void> submitOrder() async {
    if (cart.lines.isEmpty) {
      showAppToast('请先选择菜品或套餐');
      return;
    }

    isSubmitting.value = true;
    NineProgressHud.showLoading();
    try {
      final response = await CustomerMenuApi.submitOrder(
        storeId: CustomerConstants.defaultStoreId,
        tableNumber: CustomerConstants.tableNumber,
        items: cart.toOrderItems(),
      );
      if (!response.isSuccess || response.data == null) {
        showAppToast(response.message.isNotEmpty ? response.message : '结算失败');
        return;
      }
      cart.clear();
      showAppToast('下单成功，订单号 ${response.data!.orderId}');
    } finally {
      isSubmitting.value = false;
      NineProgressHud.dismiss();
    }
  }

  void goToMenuTab() {
    if (Get.isRegistered<CustomerBottomNavLogic>()) {
      final index = CustomerBottomNavLogic.to.indexOf(CustomerBottomTabType.menu);
      if (index >= 0) {
        CustomerBottomNavLogic.to.changeIndex(index);
      }
    }
  }
}
