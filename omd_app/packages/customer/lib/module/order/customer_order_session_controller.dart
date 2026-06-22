import 'package:customer/common/customer_constants.dart';
import 'package:customer/module/api/customer_menu_api.dart';
import 'package:customer/module/menu/customer_menu_models.dart';
import 'package:customer/module/store/customer_store_context_controller.dart';
import 'package:get/get.dart';

/// 当前桌号未结算订单（每店每桌仅一条）。
class CustomerOrderSessionController extends GetxController {
  static CustomerOrderSessionController get to => Get.find<CustomerOrderSessionController>();

  final currentOrder = Rxn<CustomerOrderResultModel>();

  int committedItemCountForStore(int storeId) {
    final order = currentOrder.value;
    if (order == null || order.storeId != storeId) return 0;
    return order.items.fold(0, (sum, line) => sum + line.qty);
  }

  int committedTotalCentsForStore(int storeId) {
    final order = currentOrder.value;
    if (order == null || order.storeId != storeId) return 0;
    return order.totalAmount;
  }

  Future<void> refreshCurrentOrder() async {
    final storeId = CustomerStoreContextController.to.storeId.value;
    final response = await CustomerMenuApi.getCurrentOrder(
      storeId: storeId,
      tableNumber: CustomerConstants.tableNumber,
    );
    if (!response.isSuccess) return;
    final order = response.data;
    if (order != null && order.storeId != storeId) {
      currentOrder.value = null;
      return;
    }
    currentOrder.value = order;
  }

  void applySubmittedOrder(CustomerOrderResultModel order) {
    currentOrder.value = order;
  }
}
