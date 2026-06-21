import 'package:customer/common/customer_price_utils.dart';
import 'package:customer/common/customer_translations.dart';
import 'package:customer/module/a_color/customer_colors.dart';
import 'package:customer/module/common/customer_menu_shell.dart';
import 'package:customer/module/common/customer_table_header.dart';
import 'package:customer/module/menu/customer_menu_models.dart';
import 'package:customer/module/order/customer_cart_controller.dart';
import 'package:customer/module/order/customer_order_session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomerOrderDetailPage extends StatelessWidget {
  const CustomerOrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CustomerCartController.to;
    final session = CustomerOrderSessionController.to;

    return CustomerMenuShell(
      title: CustomerCommonI18n.orderDetail.tr,
      leading: const BackButton(),
      body: Obx(() {
        final activeOrder = session.currentOrder.value;
        final hasCart = cart.lines.isNotEmpty;

        if (!hasCart && activeOrder == null) {
          return Center(
            child: Text(
              CustomerCommonI18n.emptyOrder.tr,
              style: TextStyle(color: CustomerColors.secondaryText, fontSize: 14.sp),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          children: [
            if (activeOrder != null) ...[
              _OrderMetaCard(order: activeOrder),
              SizedBox(height: 8.h),
              _SectionTitle(title: CustomerCommonI18n.committedOrderTitle.tr),
              SizedBox(height: 8.h),
              for (final line in activeOrder.items) ...[
                _CommittedLineCard(line: line),
                SizedBox(height: 8.h),
              ],
              SizedBox(height: 8.h),
            ],
            if (hasCart) ...[
              _SectionTitle(title: CustomerCommonI18n.pendingCartTitle.tr),
              SizedBox(height: 8.h),
              for (final line in cart.lines) ...[
                _CartLineCard(line: line),
                SizedBox(height: 8.h),
              ],
            ],
          ],
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: CustomerColors.secondaryText,
      ),
    );
  }
}

class _OrderMetaCard extends StatelessWidget {
  const _OrderMetaCard({required this.order});

  final CustomerOrderResultModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: CustomerColors.tabSelected.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '订单 #${order.orderId} · 桌号 ${order.tableNumber}',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            CustomerPriceUtils.formatCents(order.totalAmount),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: CustomerColors.tabSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommittedLineCard extends StatelessWidget {
  const _CommittedLineCard({required this.line});

  final CustomerOrderLineModel line;

  static const _committedGreen = Color(0xFF12B76A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              color: _committedGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 14.sp, color: _committedGreen),
          ),
          SizedBox(width: 10.w),
          Expanded(child: Text(line.name, style: TextStyle(fontSize: 15.sp))),
          Text('x${line.qty}', style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 12.w),
          Text(CustomerPriceUtils.formatCents(line.subtotal)),
        ],
      ),
    );
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({required this.line});

  final CustomerCartLine line;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  line.name,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                line.type == 'combo'
                    ? CustomerCommonI18n.comboTag.tr
                    : CustomerCommonI18n.itemTag.tr,
                style: TextStyle(fontSize: 11.sp, color: CustomerColors.secondaryText),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              CustomerPriceText(cents: line.unitPrice, fontSize: 14.sp),
              const Spacer(),
              CustomerQtyStepper(
                type: line.type,
                id: line.id,
                onAdd: () => CustomerCartController.to.increaseQty(line.key),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
