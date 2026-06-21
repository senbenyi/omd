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
    required this.selectedQty,
    required this.isSubmitting,
    required this.onSubmit,
    this.onTotalTap,
    this.canSubmit = false,
    this.submitLabel,
  });

  final int totalCents;
  final int selectedQty;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback? onTotalTap;
  final bool canSubmit;
  final String? submitLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTotalTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CustomerCommonI18n.selectedItems.trParams({'count': '$selectedQty'}),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CustomerColors.secondaryText,
                  ),
                ),
                SizedBox(height: 2.h),
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
        SizedBox(
          height: 44.h,
          child: FilledButton(
            onPressed: isSubmitting || !canSubmit ? null : onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: CustomerColors.tabSelected,
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
