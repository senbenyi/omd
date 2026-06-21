import 'package:customer/common/customer_translations.dart';
import 'package:customer/module/common/customer_checkout_bar.dart';
import 'package:customer/module/menu/customer_menu_browse_controller.dart';
import 'package:customer/module/order/customer_cart_controller.dart';
import 'package:customer/module/order/customer_order_detail_page.dart';
import 'package:customer/module/order/customer_order_session_controller.dart';
import 'package:customer/module/store/customer_store_context_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 菜单页 / 子页统一的底部栏：点击进入订单详情 + 提交。
class CustomerMenuBottomBar extends StatelessWidget {
  const CustomerMenuBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CustomerCartController.to;
    final session = CustomerOrderSessionController.to;
    final storeCtx = CustomerStoreContextController.to;
    final menu = CustomerMenuBrowseController.to;

    return Obx(() {
      final _ = cart.revision.value;
      final activeOrder = session.currentOrder.value;
      final cartTotal = cart.totalCents;
      final cartQty = cart.totalQty;
      final displayTotal = session.displayTotalCents(cartTotal);
      final canSubmit =
          !menu.isSubmitting.value &&
          cartQty > 0 &&
          storeCtx.storeOpen.value;

      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE4E7EC))),
        ),
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h + MediaQuery.paddingOf(context).bottom),
        child: CustomerCheckoutBar(
          totalCents: displayTotal,
          selectedQty: cartQty,
          isSubmitting: menu.isSubmitting.value,
          onSubmit: menu.submitOrder,
          onTotalTap: () => Get.to(() => const CustomerOrderDetailPage()),
          canSubmit: canSubmit,
          submitLabel: activeOrder != null
              ? CustomerCommonI18n.appendOrder.tr
              : CustomerCommonI18n.submitOrder.tr,
        ),
      );
    });
  }
}
