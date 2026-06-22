import 'package:common/commonui/bottom_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_models.dart';

/// 菜单模块布局常量。
abstract final class MenuLayout {
  static const divider = Color(0xFFE4E7EC);
  static const sidebarBackground = Color(0xFFF0F2F6);
  static const cardShadow = Color(0x0A18324D);
  static const tabTrackColor = Color(0xFFF5F7FB);

  static double bottomInset(BuildContext context, {required bool hasTabBar}) {
    if (hasTabBar) {
      return BottomArea.bottomBarHeigtOf(context);
    }
    return MediaQuery.paddingOf(context).bottom;
  }
}

/// 菜单页顶部标题 + 店铺选择器区域。
class MenuPageHeader extends StatelessWidget {
  const MenuPageHeader({
    super.key,
    required this.title,
    required this.storeSelector,
  });

  final String title;
  final Widget storeSelector;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 16.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: StoreColors.primaryText,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            fit: FlexFit.loose,
            child: storeSelector,
          ),
        ],
      ),
    );
  }
}

/// 店铺选择胶囊按钮。
class MenuStoreSelectorChip extends StatelessWidget {
  const MenuStoreSelectorChip({
    super.key,
    required this.label,
    this.onTap,
    this.showDropdown = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool showDropdown;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: MenuLayout.divider),
        boxShadow: const [
          BoxShadow(
            color: MenuLayout.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 16.sp,
            color: StoreColors.tabSelected,
          ),
          SizedBox(width: 6.w),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: StoreColors.primaryText,
              ),
            ),
          ),
          if (showDropdown) ...[
            SizedBox(width: 2.w),
            Icon(
              Icons.expand_more_rounded,
              size: 18.sp,
              color: StoreColors.tabSelected,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: child,
      ),
    );
  }
}

/// 菜单页顶部分类 / 套餐 / 已售罄 / 已下架大 Tab。
class MenuMainTabBar extends StatelessWidget {
  const MenuMainTabBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final MenuSidebarKind selected;
  final ValueChanged<MenuSidebarKind> onChanged;

  static const _tabs = [
    (MenuSidebarKind.category, StoreMenuI18n.categorySectionLabel),
    (MenuSidebarKind.combo, StoreMenuI18n.comboSectionLabel),
    (MenuSidebarKind.soldOut, StoreMenuI18n.soldOutSectionLabel),
    (MenuSidebarKind.offShelf, StoreMenuI18n.offShelfSectionLabel),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
      child: Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: MenuLayout.tabTrackColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.all(3.w),
        child: Row(
          children: [
            for (var i = 0; i < _tabs.length; i++) ...[
              if (i > 0) SizedBox(width: 2.w),
              Expanded(
                child: _MenuMainTabItem(
                  label: _tabs[i].$2.tr,
                  selected: selected == _tabs[i].$1,
                  onTap: () => onChanged(_tabs[i].$1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuMainTabItem extends StatelessWidget {
  const _MenuMainTabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? StoreColors.tabSelected : StoreColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}

/// 空状态占位。
class MenuEmptyState extends StatelessWidget {
  const MenuEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.restaurant_menu_outlined,
    this.actionHint,
  });

  final String message;
  final IconData icon;
  final String? actionHint;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: StoreColors.tabSelected.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 32.sp,
                color: StoreColors.tabSelected.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: StoreColors.secondaryText,
                height: 1.5,
              ),
            ),
            if (actionHint != null && actionHint!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                actionHint!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: StoreColors.tabSelected.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
