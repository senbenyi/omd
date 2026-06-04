import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store/module/a_color/store_colors.dart';

abstract final class MenuSoldOutLayout {
  static const divider = Color(0xFFE4E7EC);
}

class MenuSoldOutEmptyState extends StatelessWidget {
  const MenuSoldOutEmptyState({
    super.key,
    required this.message,
    this.icon,
  });

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 40.sp, color: StoreColors.secondaryText),
          if (icon != null) SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(fontSize: 13.sp, color: StoreColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class MenuSoldOutPanelHeader extends StatelessWidget {
  const MenuSoldOutPanelHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: MenuSoldOutLayout.divider)),
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: StoreColors.tabSelected.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(leadingIcon, size: 18.sp, color: StoreColors.tabSelected),
            ),
            SizedBox(width: 10.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: StoreColors.primaryText,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: StoreColors.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
