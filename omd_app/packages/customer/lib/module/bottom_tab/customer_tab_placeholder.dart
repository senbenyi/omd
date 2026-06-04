import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:customer/module/a_color/customer_colors.dart';

/// Tab 页占位，后续替换为真实业务页面。
class CustomerTabPlaceholder extends StatelessWidget {
  const CustomerTabPlaceholder({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CustomerColors.scaffoldBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              child: Text(
                title.tr,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: CustomerColors.primaryText,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 56.sp, color: CustomerColors.tabSelected),
                    SizedBox(height: 16.h),
                    Text(
                      description.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CustomerColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
