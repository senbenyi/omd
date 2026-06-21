import 'package:customer/common/customer_translations.dart';
import 'package:customer/module/a_color/customer_colors.dart';
import 'package:customer/module/common/customer_table_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomerCheckoutBar extends StatelessWidget {
  const CustomerCheckoutBar({
    super.key,
    required this.totalCents,
    required this.committedQty,
    required this.pendingQty,
    required this.isSubmitting,
    required this.onSubmit,
    this.onTotalTap,
    this.canSubmit = false,
    this.submitLabel,
  });

  final int totalCents;
  final int committedQty;
  final int pendingQty;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback? onTotalTap;
  final bool canSubmit;
  final String? submitLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTotalTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (committedQty > 0) ...[
                  Text(
                    CustomerCommonI18n.committedDishes.trParams({
                      'count': '$committedQty',
                    }),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: CustomerColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
                if (pendingQty > 0) ...[
                  Text(
                    CustomerCommonI18n.pendingDishes.trParams({
                      'count': '$pendingQty',
                    }),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: CustomerColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
                Text(
                  CustomerCommonI18n.totalLabel.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CustomerColors.secondaryText,
                  ),
                ),
                CustomerPriceText(cents: totalCents, fontSize: 22.sp),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          height: 44.h,
          child: FilledButton(
            onPressed: isSubmitting || !canSubmit ? null : onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: CustomerColors.tabSelected,
              disabledBackgroundColor: const Color(0xFFE4E7EC),
              disabledForegroundColor: CustomerColors.secondaryText,
              padding: EdgeInsets.symmetric(horizontal: 28.w),
            ),
            child: Text(
              isSubmitting
                  ? CustomerCommonI18n.submitting.tr
                  : (submitLabel ?? CustomerCommonI18n.submitOrder.tr),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
