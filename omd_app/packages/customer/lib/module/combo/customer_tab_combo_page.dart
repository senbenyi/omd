import 'package:customer/common/customer_translations.dart';
import 'package:customer/module/a_color/customer_colors.dart';
import 'package:customer/module/combo/customer_tab_combo_controller.dart';
import 'package:customer/module/common/customer_table_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomerTabComboPage extends StatelessWidget {
  const CustomerTabComboPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerTabComboController());
    return Scaffold(
      backgroundColor: CustomerColors.scaffoldBackground,
      appBar: CustomerTableHeader(title: CustomerCommonI18n.tabCombo.tr),
      body: Obx(() {
        if (controller.isLoading.value && controller.combos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty && controller.combos.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.errorMessage.value, textAlign: TextAlign.center),
                SizedBox(height: 16.h),
                FilledButton(
                  onPressed: controller.loadCombos,
                  child: Text(CustomerCommonI18n.retry.tr),
                ),
              ],
            ),
          );
        }
        if (controller.combos.isEmpty) {
          return Center(
            child: Text(
              CustomerCommonI18n.emptyCombo.tr,
              style: TextStyle(color: CustomerColors.secondaryText, fontSize: 14.sp),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadCombos,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
            itemCount: controller.combos.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final combo = controller.combos[index];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            combo.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: CustomerColors.primaryText,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${combo.itemCount} 道菜',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: CustomerColors.secondaryText,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          CustomerPriceText(cents: combo.price),
                        ],
                      ),
                    ),
                    CustomerQtyStepper(
                      type: 'combo',
                      id: combo.id,
                      onAdd: () => controller.addToCart(combo),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
