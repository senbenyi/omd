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
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget storeSelector;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 16.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
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
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: StoreColors.secondaryText,
                    ),
                  ),
                ],
              ],
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
      elevation: selected ? 0 : 0,
      shadowColor: MenuLayout.cardShadow,
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
/// 右侧内容区顶栏。
class MenuPanelHeader extends StatelessWidget {
  const MenuPanelHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.priceText,
    this.leadingIcon,
  });

  final String title;
  final String? subtitle;
  final String? priceText;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: MenuLayout.divider)),
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
          if (priceText != null && priceText!.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: StoreColors.tabSelected.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                priceText!,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: StoreColors.tabSelected,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 侧边栏分类/套餐条目。
class MenuSidebarTile extends StatelessWidget {
  const MenuSidebarTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

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
                          color: MenuLayout.cardShadow,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                      : null,
              border:
                  selected
                      ? Border.all(
                        color: MenuLayout.divider.withValues(alpha: 0.6),
                      )
                      : null,
            ),
            padding: EdgeInsets.fromLTRB(
              selected ? 10.w : 12.w,
              12.h,
              8.w,
              12.h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight:
                                    selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                color:
                                    selected
                                        ? StoreColors.tabSelected
                                        : StoreColors.primaryText,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 侧边栏底部添加操作。
class MenuSidebarActionButton extends StatelessWidget {
  const MenuSidebarActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.add_rounded,
  });

  final String label;
  final VoidCallback onTap;
  final IconData icon;

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
                child: Icon(icon, size: 14.sp, color: StoreColors.tabSelected),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 底部/行内添加操作：悬浮圆角条。
class MenuAddActionBar extends StatelessWidget {
  const MenuAddActionBar({
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
        elevation: 0,
        shadowColor: MenuLayout.cardShadow,
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
              boxShadow: const [
                BoxShadow(
                  color: MenuLayout.cardShadow,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
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

/// 菜品列表标签数据。
class MenuDishTagData {
  const MenuDishTagData({
    required this.label,
    required this.color,
    this.outlined = false,
  });

  final String label;
  final Color color;
  final bool outlined;
}

/// 菜品操作色（售罄 / 下架 / 上架）。
abstract final class MenuDishActionColors {
  static const soldOutFg = Color(0xFF92400E);
  static const soldOutBg = Color(0xFFFEF3C7);
  static const soldOutBadgeFg = Color(0xFF78350F);
  static const soldOutBadgeBg = Color(0xFFFDE68A);

  static const offShelfFg = Color(0xFF52525B);
  static const offShelfBg = Color(0xFFF4F4F5);
  static const offShelfBorder = Color(0xFFE4E4E7);

  static const onShelfFg = Color(0xFF166534);
  static const onShelfBg = Color(0xFFDCFCE7);
  static const onShelfBorder = Color(0xFFBBF7D0);
}

/// 菜品列表操作按钮。
class MenuItemAction {
  const MenuItemAction({
    required this.label,
    required this.onTap,
    this.destructive = false,
    this.foreground,
    this.background,
    this.borderColor,
  });

  final String label;
  final VoidCallback onTap;
  final bool destructive;
  final Color? foreground;
  final Color? background;
  final Color? borderColor;
}

/// 卡片右上角标签（贴角、圆角背景、不同标签不同色）。
class MenuDishCardTagBar extends StatelessWidget {
  const MenuDishCardTagBar({
    super.key,
    required this.tags,
    required this.cardCornerRadius,
  });

  static const _palette = <(Color bg, Color fg)>[
    (Color(0xFFFFB454), Color(0xFF7C2D12)),
    (Color(0xFF60A5FA), Color(0xFF1E3A8A)),
    (Color(0xFF4ADE80), Color(0xFF14532D)),
    (Color(0xFFC084FC), Color(0xFF581C87)),
    (Color(0xFFF87171), Color(0xFF991B1B)),
    (Color(0xFF22D3EE), Color(0xFF155E75)),
  ];

  static const _namedTags = <String, (Color bg, Color fg)>{
    '上架': (Color(0xFF4ADE80), Color(0xFF14532D)),
    '在售': (Color(0xFF4ADE80), Color(0xFF14532D)),
    '推荐': (Color(0xFFFB923C), Color(0xFF7C2D12)),
    '新品': (Color(0xFF38BDF8), Color(0xFF0C4A6E)),
    '热销': (Color(0xFFF472B6), Color(0xFF831843)),
    '限时': (Color(0xFFFACC15), Color(0xFF713F12)),
  };

  final List<String> tags;
  final double cardCornerRadius;

  (Color bg, Color fg) _colorsFor(String tag, int index) {
    return _namedTags[tag] ??
        _palette[(tag.hashCode.abs() + index) % _palette.length];
  }

  Widget _buildTagChip(String tag, int index) {
    final (bg, fg) = _colorsFor(tag, index);
    final isFirst = index == 0;
    final isLast = index == tags.length - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isFirst ? 10.w : 8.w,
        5.h,
        isLast ? 10.w : 8.w,
        5.h,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.only(
          topRight: isLast ? Radius.circular(cardCornerRadius) : Radius.zero,
          bottomLeft: isFirst ? Radius.circular(8.r) : Radius.zero,
        ),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: fg,
          height: 1.1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < tags.length; i++) _buildTagChip(tags[i], i),
      ],
    );
  }
}

/// 菜品缩略图占位（首字渐变底）。
class MenuDishThumbnail extends StatelessWidget {
  const MenuDishThumbnail({
    super.key,
    required this.name,
    this.size = 56,
    this.width,
    this.fillParent = false,
    this.borderRadius,
  });

  final String name;
  final double size;
  final double? width;
  final bool fillParent;
  final BorderRadius? borderRadius;

  BoxDecoration _gradientDecoration(BorderRadius radius) {
    return BoxDecoration(
      borderRadius: radius,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          StoreColors.tabSelected.withValues(alpha: 0.18),
          StoreColors.tabSelected.withValues(alpha: 0.06),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial =
        name.isNotEmpty ? String.fromCharCode(name.runes.first) : '?';
    final boxWidth = fillParent ? double.infinity : (width ?? size).w;
    final boxHeight = fillParent ? double.infinity : (width ?? size).w;
    final radius =
        borderRadius ?? BorderRadius.circular((size * 0.2).r);
    final side = fillParent ? size.w : (width ?? size).w;
    final fontSize = (side * 0.36).clamp(14.0, 22.0).sp;

    return Container(
      width: boxWidth,
      height: boxHeight,
      decoration: _gradientDecoration(radius),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: StoreColors.tabSelected,
        ),
      ),
    );
  }
}

class MenuItemStatusBadge extends StatelessWidget {
  const MenuItemStatusBadge({
    super.key,
    required this.isOnSale,
    required this.onSaleLabel,
    required this.offSaleLabel,
    this.compact = false,
  });

  final bool isOnSale;
  final String onSaleLabel;
  final String offSaleLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color =
        isOnSale ? const Color(0xFF12B76A) : StoreColors.secondaryText;
    final label = isOnSale ? onSaleLabel : offSaleLabel;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6.w : 8.w,
        vertical: compact ? 2.h : 5.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(compact ? 4.r : 20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 5.w : 6.w,
            height: compact ? 5.w : 6.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 10.sp : 11.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
