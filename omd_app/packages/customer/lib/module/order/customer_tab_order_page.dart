import 'package:customer/common/customer_price_utils.dart';
import 'package:customer/common/customer_translations.dart';
import 'package:customer/module/a_color/customer_colors.dart';
import 'package:customer/module/common/customer_table_header.dart';
import 'package:customer/module/order/customer_cart_controller.dart';
import 'package:customer/module/order/customer_tab_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomerTabOrderPage extends StatelessWidget {
  const CustomerTabOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerTabOrderController());
    final cart = CustomerCartController.to;
    return Scaffold(
      backgroundColor: CustomerColors.scaffoldBackground,
      appBar: CustomerTableHeader(title: CustomerCommonI18n.tabOrder.tr),
      body: Obx(() {
        if (cart.lines.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CustomerCommonI18n.emptyOrder.tr,
                  style: TextStyle(color: CustomerColors.secondaryText, fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),
                OutlinedButton(
                  onPressed: controller.goToMenuTab,
                  child: Text(CustomerCommonI18n.goOrder.tr),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                itemCount: cart.lines.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final line = cart.lines[index];
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
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              line.type == 'combo'
                                  ? CustomerCommonI18n.comboTag.tr
                                  : CustomerCommonI18n.itemTag.tr,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: CustomerColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            CustomerPriceText(cents: line.unitPrice, fontSize: 14.sp),
                            const Spacer(),
                            _QtyStepper(
                              qty: line.qty,
                              onMinus: () => cart.decreaseQty(line.key),
                              onPlus: () => cart.increaseQty(line.key),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '小计 ${CustomerPriceUtils.formatCents(line.subtotal)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CustomerColors.primaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _CheckoutBar(
              totalCents: cart.totalCents,
              isSubmitting: controller.isSubmitting.value,
              onSubmit: controller.submitOrder,
            ),
          ],
        );
      }),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(icon: Icons.remove, onPressed: onMinus),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text('$qty', style: TextStyle(fontSize: 15.sp)),
        ),
        _RoundIconButton(icon: Icons.add, onPressed: onPlus),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE4E7EC)),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(icon, size: 16.sp),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.totalCents,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final int totalCents;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4E7EC))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CustomerCommonI18n.totalLabel.tr,
                  style: TextStyle(fontSize: 12.sp, color: CustomerColors.secondaryText),
                ),
                CustomerPriceText(cents: totalCents, fontSize: 22.sp),
              ],
            ),
          ),
          SizedBox(
            height: 44.h,
            child: FilledButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: CustomerColors.tabSelected,
                padding: EdgeInsets.symmetric(horizontal: 28.w),
              ),
              child: Text(
                isSubmitting
                    ? CustomerCommonI18n.submitting.tr
                    : CustomerCommonI18n.checkout.tr,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
