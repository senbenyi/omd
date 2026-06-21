import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/order/store_order_i18n.dart';

class StoreOrderStatusChip extends StatelessWidget {
  const StoreOrderStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final pending = status == 'pending';
    final color = pending ? const Color(0xFF1677FF) : const Color(0xFF667085);
    final label = pending
        ? StoreOrderI18n.statusPending.tr
        : StoreOrderI18n.statusSettled.tr;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12.sp, color: color),
      ),
    );
  }
}
