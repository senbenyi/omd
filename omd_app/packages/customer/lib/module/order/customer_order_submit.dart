import 'package:base/toast/nine_toast.dart';
import 'package:customer/common/customer_constants.dart';
import 'package:customer/module/api/customer_menu_api.dart';
import 'package:customer/module/order/customer_cart_controller.dart';
import 'package:customer/module/order/customer_order_session_controller.dart';

Future<bool> submitCustomerOrder({
  required int storeId,
  int tableNumber = CustomerConstants.tableNumber,
}) async {
  final cart = CustomerCartController.to;
  if (cart.lines.isEmpty) {
    showAppToast('请先选择菜品或套餐');
    return false;
  }

  final session = CustomerOrderSessionController.to;
  final activeOrder = session.currentOrder.value;
  final existingOrderId =
      activeOrder != null && activeOrder.storeId == storeId
          ? activeOrder.orderId
          : null;
  final isAppend = existingOrderId != null;

  final response = await CustomerMenuApi.submitOrder(
    storeId: storeId,
    tableNumber: tableNumber,
    items: cart.toOrderItems(),
    orderId: existingOrderId,
  );
  if (!response.isSuccess || response.data == null) {
    showAppToast(response.message.isNotEmpty ? response.message : '提交失败');
    return false;
  }

  session.applySubmittedOrder(response.data!);
  cart.clearLines();
  showAppToast(
    isAppend
        ? '提交成功，订单号 ${response.data!.orderId}'
        : '下单成功，订单号 ${response.data!.orderId}',
  );
  return true;
}
