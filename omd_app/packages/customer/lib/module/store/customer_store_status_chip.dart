import 'package:customer/common/customer_translations.dart';
import 'package:customer/module/a_color/customer_colors.dart';
import 'package:customer/module/store/customer_store_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 店铺营业状态标签（open / rest）。
class CustomerStoreStatusChip extends StatelessWidget {
  const CustomerStoreStatusChip({super.key, required this.store});

  final CustomerStoreModel store;

  @override
  Widget build(BuildContext context) {
    final isOpen = store.isOpen;
    final color =
        isOpen ? const Color(0xFF12B76A) : CustomerColors.secondaryText;
    final label =
        isOpen
            ? CustomerCommonI18n.storeStatusOpen.tr
            : CustomerCommonI18n.storeStatusRest.tr;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
