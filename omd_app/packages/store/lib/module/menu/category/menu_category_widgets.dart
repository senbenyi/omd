import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_core_widgets.dart';
import 'package:store/module/menu/menu_price_utils.dart';

export 'menu_categoty_dish_item.dart';

/// 菜品/套餐内菜品列表卡片（售罄/下架 Tab 等复用）。
class MenuDishListTile extends StatelessWidget {
  static const _thumbLogicalSize = 48.0;

  const MenuDishListTile({
    super.key,
    required this.name,
    required this.price,
    this.categoryName,
    this.tags = const [],
    this.createdAt,
    this.soldOut = false,
    this.soldOutLabel,
    this.isOnSale = true,
    this.onSaleLabel,
    this.offSaleLabel,
    this.showStatusBadges = false,
    this.actions = const [],
    this.onTap,
  });

  final String name;
  final int price;
  final String? categoryName;
  final List<String> tags;
  final String? createdAt;
  final bool soldOut;
  final String? soldOutLabel;
  final bool isOnSale;
  final String? onSaleLabel;
  final String? offSaleLabel;
  final bool showStatusBadges;
  final List<MenuItemAction> actions;
  final VoidCallback? onTap;

  List<MenuDishTagData> _collectMetaTags() {
    final chips = <MenuDishTagData>[];
    if (showStatusBadges && onSaleLabel != null && offSaleLabel != null) {
      chips.add(
        MenuDishTagData(
          label: isOnSale ? onSaleLabel! : offSaleLabel!,
          color: isOnSale ? MenuDishActionColors.onShelfFg : MenuDishActionColors.offShelfFg,
          outlined: !isOnSale,
        ),
      );
    }
    if (soldOut && soldOutLabel != null) {
      chips.add(
        MenuDishTagData(
          label: soldOutLabel!,
          color: MenuDishActionColors.soldOutFg,
        ),
      );
    }
    return chips;
  }

  Widget _buildMetaBadge(MenuDishTagData data) {
    final fg = data.color;
    final bg =
        data.outlined
            ? MenuDishActionColors.offShelfBg
            : fg.withValues(alpha: 0.12);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: fg.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Text(
        data.label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: fg,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildPriceSection(List<MenuDishTagData> metaTags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          MenuPriceUtils.formatCents(price),
          style: TextStyle(
            fontSize: 14.sp,
            color: StoreColors.tabSelected,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        if (categoryName != null && categoryName!.isNotEmpty) ...[
          SizedBox(height: 3.h),
          Text(
            categoryName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              color: StoreColors.secondaryText,
              height: 1.1,
            ),
          ),
        ],
        if (metaTags.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Wrap(
            spacing: 4.w,
            runSpacing: 4.h,
            children: metaTags.map(_buildMetaBadge).toList(),
          ),
        ],
      ],
    );
  }

  Widget _maybeTap(Widget child) {
    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: child,
      ),
    );
  }

  Widget _buildMainPanel() {
    final hasActions = actions.isNotEmpty;
    final metaTags = _collectMetaTags();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _maybeTap(
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: StoreColors.primaryText,
              height: 1.25,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        _maybeTap(_buildPriceSection(metaTags)),
        if (hasActions) ...[
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              for (var i = 0; i < actions.length; i++)
                _MenuItemActionButton(action: actions[i], dense: true),
            ],
          ),
        ],
      ],
    );
  }

  /// 估算右侧内容高度，使图片顶对齐 name、底对齐操作按钮。
  double _tileThumbHeight(BuildContext context) {
    final hasActions = actions.isNotEmpty;
    final metaTags = _collectMetaTags();
    final nameLineHeight = 15.sp * 1.25;
    final nameLines = name.runes.length > 14 ? 2 : 1;

    var h = nameLineHeight * nameLines;
    h += 4.h + 14.sp * 1.2;
    if (categoryName != null && categoryName!.isNotEmpty) {
      h += 3.h + 10.sp * 1.1;
    }
    if (metaTags.isNotEmpty) {
      h += 4.h + 20.h;
    }
    if (hasActions) {
      h += 8.h + 27.h;
    }
    final minH = _thumbLogicalSize.w;
    return h < minH ? minH : h;
  }

  @override
  Widget build(BuildContext context) {
    final hasTags = tags.isNotEmpty;
    final cardRadius = 12.r;
    final thumbRadius = BorderRadius.circular(8.r);
    final thumbHeight = _tileThumbHeight(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: MenuLayout.divider.withValues(alpha: 0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 9.h, 10.w, 9.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _thumbLogicalSize.w,
                  height: thumbHeight,
                  child: MenuDishThumbnail(
                    name: name,
                    size: _thumbLogicalSize,
                    fillParent: true,
                    borderRadius: thumbRadius,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: hasTags ? 6.w : 0,
                    ),
                    child: _buildMainPanel(),
                  ),
                ),
              ],
            ),
          ),
          if (hasTags)
            Positioned(
              top: 0,
              right: 0,
              child: MenuDishCardTagBar(
                tags: tags,
                cardCornerRadius: cardRadius,
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuItemActionButton extends StatelessWidget {
  const _MenuItemActionButton({required this.action, this.dense = false});

  final MenuItemAction action;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color =
        action.destructive
            ? const Color(0xFFF04438)
            : (action.foreground ?? StoreColors.tabSelected);
    final bg =
        action.background ??
        (action.destructive
            ? const Color(0xFFFEF2F2)
            : color.withValues(alpha: dense ? 0.08 : 0.06));
    final borderColor = action.borderColor ?? color.withValues(alpha: 0.12);

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dense ? 5.r : 6.r),
        side: BorderSide(color: borderColor, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: action.onTap,
        splashColor: color.withValues(alpha: 0.08),
        highlightColor: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(dense ? 5.r : 6.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 8.w : 10.w,
            vertical: dense ? 4.h : 5.h,
          ),
          child: Text(
            action.label,
            style: TextStyle(
              fontSize: dense ? 11.sp : 12.sp,
              fontWeight: FontWeight.w500,
              color: color,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}

/// 列表项内胶囊双选分段（滑块左右滑动动画，点击乐观更新）。
class MenuDishMiniSegment extends StatefulWidget {
  const MenuDishMiniSegment({
    super.key,
    required this.value,
    required this.leftLabel,
    required this.rightLabel,
    required this.onChanged,
    this.leftSelectedColor,
    this.rightSelectedColor,
    this.width,
  });

  static const _animDuration = Duration(milliseconds: 220);

  static double get defaultWidth => 72.w;

  final bool value;
  final String leftLabel;
  final String rightLabel;
  final Future<bool> Function(bool value) onChanged;
  final Color? leftSelectedColor;
  final Color? rightSelectedColor;
  final double? width;

  @override
  State<MenuDishMiniSegment> createState() => _MenuDishMiniSegmentState();
}

class _MenuDishMiniSegmentState extends State<MenuDishMiniSegment> {
  late bool _value;
  var _pending = false;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(MenuDishMiniSegment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_pending && oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  Future<void> _commit(bool next) async {
    if (next == _value || _pending) return;
    setState(() {
      _value = next;
      _pending = true;
    });

    final ok = await widget.onChanged(next);
    if (!mounted) return;

    setState(() {
      _pending = false;
      if (!ok) {
        _value = widget.value;
      } else if (widget.value != _value) {
        _value = widget.value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackHeight = 26.h;
    final trackRadius = trackHeight / 2;
    final inset = 2.w;
    final thumbRadius = trackRadius - inset;
    final trackWidth = widget.width ?? MenuDishMiniSegment.defaultWidth;

    return SizedBox(
      height: trackHeight,
      width: trackWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFEEF0F4),
          borderRadius: BorderRadius.circular(trackRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(inset),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final thumbWidth = constraints.maxWidth / 2;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: MenuDishMiniSegment._animDuration,
                    curve: Curves.easeInOutCubic,
                    left: _value ? thumbWidth : 0,
                    top: 0,
                    bottom: 0,
                    width: thumbWidth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(thumbRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _DishMiniSegmentLabel(
                          label: widget.leftLabel,
                          selected: !_value,
                          selectedColor:
                              widget.leftSelectedColor ??
                              StoreColors.tabSelected,
                          onTap: () => _commit(false),
                        ),
                      ),
                      Expanded(
                        child: _DishMiniSegmentLabel(
                          label: widget.rightLabel,
                          selected: _value,
                          selectedColor:
                              widget.rightSelectedColor ??
                              StoreColors.tabSelected,
                          onTap: () => _commit(true),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DishMiniSegmentLabel extends StatelessWidget {
  const _DishMiniSegmentLabel({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        splashColor: StoreColors.tabSelected.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: MenuDishMiniSegment._animDuration,
            curve: Curves.easeInOutCubic,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? selectedColor : StoreColors.secondaryText,
              height: 1.1,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

