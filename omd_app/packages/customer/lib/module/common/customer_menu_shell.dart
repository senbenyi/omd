import 'package:customer/common/customer_constants.dart';
import 'package:customer/common/customer_translations.dart';
import 'package:customer/module/a_color/customer_colors.dart';
import 'package:customer/module/common/customer_menu_bottom_bar.dart';
import 'package:customer/module/store/customer_store_context_controller.dart';
import 'package:customer/module/store/customer_store_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 带固定底部提交栏的页面壳（菜单主页与子页共用）。
class CustomerMenuShell extends StatelessWidget {
  const CustomerMenuShell({
    super.key,
    required this.body,
    this.title,
    this.leading,
    this.showStoreButton = false,
    this.showRestHint = false,
  });

  final Widget body;
  final String? title;
  final Widget? leading;
  final bool showStoreButton;
  final bool showRestHint;

  @override
  Widget build(BuildContext context) {
    final storeCtx = CustomerStoreContextController.to;

    return Scaffold(
      backgroundColor: CustomerColors.scaffoldBackground,
      appBar: AppBar(
        leading: leading ?? (showStoreButton ? _StoreLeadingButton() : null),
        automaticallyImplyLeading: !showStoreButton && leading == null,
        title: title != null
            ? Text(title!)
            : Obx(() => Text(storeCtx.storeName.value)),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Text(
                '桌号 ${CustomerConstants.tableNumber}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: CustomerColors.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (showRestHint)
            Obx(() {
              if (storeCtx.storeOpen.value) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                color: const Color(0xFFFFF4E5),
                child: Text(
                  CustomerCommonI18n.storeRestHint.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFFB54708)),
                ),
              );
            }),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: const CustomerMenuBottomBar(),
    );
  }
}

class _StoreLeadingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Get.to(() => const CustomerStoreListPage()),
      child: Text(
        CustomerCommonI18n.tabStore.tr,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: CustomerColors.tabSelected,
        ),
      ),
    );
  }
}
