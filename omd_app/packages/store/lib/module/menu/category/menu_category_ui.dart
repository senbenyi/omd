import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store/module/a_color/store_colors.dart';

/// 分类 Tab 专用布局与通用组件（不与其他 Tab 共用）。
abstract final class MenuCategoryLayout {
  static const divider = Color(0xFFE4E7EC);
  static const sidebarBackground = Color(0xFFF0F2F6);
  static const cardShadow = Color(0x0A18324D);
}

class MenuCategoryEmptyState extends StatelessWidget {
  const MenuCategoryEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.actionHint,
  });

  final String message;
  final IconData? icon;
  final String? actionHint;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon, size: 40.sp, color: StoreColors.secondaryText),
            if (icon != null) SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: StoreColors.secondaryText),
            ),
            if (actionHint != null && actionHint!.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                actionHint!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: StoreColors.tabSelected),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MenuCategorySidebarTile extends StatelessWidget {
  const MenuCategorySidebarTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow:
                  selected
                      ? const [
                        BoxShadow(
                          color: MenuCategoryLayout.cardShadow,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                      : null,
              border:
                  selected
                      ? Border.all(
                        color: MenuCategoryLayout.divider.withValues(alpha: 0.6),
                      )
                      : null,
            ),
            padding: EdgeInsets.fromLTRB(
              selected ? 10.w : 12.w,
              12.h,
              8.w,
              12.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        selected
                            ? StoreColors.tabSelected
                            : StoreColors.primaryText,
                    height: 1.3,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: StoreColors.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MenuCategorySidebarActionButton extends StatelessWidget {
  const MenuCategorySidebarActionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 12.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: StoreColors.tabSelected,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: StoreColors.tabSelected.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.add_rounded,
                  size: 14.sp,
                  color: StoreColors.tabSelected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuCategoryPanelHeader extends StatelessWidget {
  const MenuCategoryPanelHeader({
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
        border: Border(bottom: BorderSide(color: MenuCategoryLayout.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: StoreColors.tabSelected.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                leadingIcon,
                size: 18.sp,
                color: StoreColors.tabSelected,
              ),
            ),
            SizedBox(width: 10.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: StoreColors.primaryText,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
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

class MenuCategoryAddActionBar extends StatelessWidget {
  const MenuCategoryAddActionBar({
    super.key,
    required this.label,
    required this.onTap,
    this.bottomInset = 0,
  });

  final String label;
  final VoidCallback onTap;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h + bottomInset),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: StoreColors.tabSelected.withValues(alpha: 0.25),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 20.sp,
                    color: StoreColors.tabSelected,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: StoreColors.tabSelected,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
