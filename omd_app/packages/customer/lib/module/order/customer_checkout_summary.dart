import 'package:customer/module/order/customer_cart_controller.dart';
import 'package:customer/module/order/customer_order_session_controller.dart';

/// 底部提交栏汇总：已下单 / 待提交数量、总价、是否可提交。
class CustomerCheckoutSummary {
  const CustomerCheckoutSummary({
    required this.committedQty,
    required this.pendingQty,
    required this.totalCents,
    required this.canSubmit,
    required this.isAppend,
  });

  final int committedQty;
  final int pendingQty;
  final int totalCents;
  final bool canSubmit;
  final bool isAppend;
}

extension CustomerOrderSessionCheckout on CustomerOrderSessionController {
  CustomerCheckoutSummary buildCheckoutSummary({
    required int storeId,
    required bool storeOpen,
    required bool isSubmitting,
    required CustomerCartController cart,
  }) {
    final order = currentOrder.value;
    final orderMatchesStore =
        order == null || order.storeId == storeId;
    final cartMatchesStore =
        cart.storeId == null || cart.storeId == storeId;

    final committedQty = committedItemCountForStore(storeId);
    final committedTotal = committedTotalCentsForStore(storeId);
    final pendingQty = cartMatchesStore ? cart.totalQty : 0;
    final pendingTotal = cartMatchesStore ? cart.totalCents : 0;

    return CustomerCheckoutSummary(
      committedQty: committedQty,
      pendingQty: pendingQty,
      totalCents: committedTotal + pendingTotal,
      canSubmit:
          !isSubmitting &&
          cart.totalQty > 0 &&
          cartMatchesStore &&
          orderMatchesStore &&
          storeOpen,
      isAppend: orderMatchesStore && order != null,
    );
  }
}
