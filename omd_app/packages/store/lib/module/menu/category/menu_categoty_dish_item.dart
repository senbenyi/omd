import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_price_utils.dart';

/// 分类列表底部操作（售罄 / 下架）。
class MenuDishCategoryActions {
  const MenuDishCategoryActions({
    required this.soldOut,
    required this.onMarkSoldOut,
    required this.onTakeOffShelf,
  });

  final bool soldOut;
  final Future<bool> Function() onMarkSoldOut;
  final Future<bool> Function() onTakeOffShelf;
}

/// 分类 Tab 菜品卡片（设计稿：左图右文 + 售罄/下架 + 右上角标签）。
class MenuCategoryDishItem extends StatelessWidget {
  const MenuCategoryDishItem({
    super.key,
    required this.name,
    required this.price,
    this.tags = const [],
    this.categoryActions,
    this.onTap,
  });

  static const _accentBlue = Color(0xFF1890FF);
  static const _thumbBg = Color(0xFFE6F0FF);
  static const _soldOutBg = Color(0xFFFFF1B8);
  static const _soldOutFg = Color(0xFF874D00);
  static const _offShelfBg = Color(0xFFF5F5F5);
  static const _offShelfFg = Color(0xFF595959);

  static const _thumbWidth = 56.0;
  static const _thumbHeight = 72.0;

  final String name;
  final int price;
  final List<String> tags;
  final MenuDishCategoryActions? categoryActions;
  final VoidCallback? onTap;

  String get _initial =>
      name.isNotEmpty ? String.fromCharCode(name.runes.first) : '?';

  @override
  Widget build(BuildContext context) {
    final cardRadius = 12.r;
    final hasTag = tags.isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryDishThumb(
                    initial: _initial,
                    width: _thumbWidth.w,
                    height: _thumbHeight.h,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF000000),
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          MenuPriceUtils.formatCents(price),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: _accentBlue,
                            height: 1.2,
                          ),
                        ),
                        if (categoryActions != null) ...[
                          SizedBox(height: 10.h),
                          _MenuCategoryDishFooter(actions: categoryActions!),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (hasTag)
              Positioned(
                top: 0,
                right: 0,
                child: _CategoryCornerTag(
                  label: tags.first,
                  cardCornerRadius: cardRadius,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDishThumb extends StatelessWidget {
  const _CategoryDishThumb({
    required this.initial,
    required this.width,
    required this.height,
  });

  final String initial;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: MenuCategoryDishItem._thumbBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.w600,
          color: MenuCategoryDishItem._accentBlue,
          height: 1,
        ),
      ),
    );
  }
}

/// 右上角标签（新品等），贴卡片右上、左下圆角。
class _CategoryCornerTag extends StatelessWidget {
  const _CategoryCornerTag({
    required this.label,
    required this.cardCornerRadius,
  });

  final String label;
  final double cardCornerRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 4.h),
      decoration: BoxDecoration(
        color: MenuCategoryDishItem._accentBlue,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(cardCornerRadius),
          bottomLeft: Radius.circular(8.r),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.1,
        ),
      ),
    );
  }
}

class _MenuCategoryDishFooter extends StatefulWidget {
  const _MenuCategoryDishFooter({required this.actions});

  final MenuDishCategoryActions actions;

  @override
  State<_MenuCategoryDishFooter> createState() => _MenuCategoryDishFooterState();
}

class _MenuCategoryDishFooterState extends State<_MenuCategoryDishFooter> {
  var _soldOut = false;
  var _markingSoldOut = false;
  var _takingOff = false;

  @override
  void initState() {
    super.initState();
    _soldOut = widget.actions.soldOut;
  }

  @override
  void didUpdateWidget(_MenuCategoryDishFooter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_markingSoldOut && oldWidget.actions.soldOut != widget.actions.soldOut) {
      _soldOut = widget.actions.soldOut;
    }
  }

  Future<void> _markSoldOut() async {
    if (_soldOut || _markingSoldOut) return;
    setState(() => _markingSoldOut = true);
    final ok = await widget.actions.onMarkSoldOut();
    if (!mounted) return;
    setState(() {
      _markingSoldOut = false;
      if (ok) _soldOut = true;
    });
  }

  Future<void> _takeOffShelf() async {
    if (_takingOff) return;
    setState(() => _takingOff = true);
    await widget.actions.onTakeOffShelf();
    if (mounted) setState(() => _takingOff = false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (_soldOut)
          _CategoryFooterChip(
            label: StoreMenuI18n.soldOutSectionLabel.tr,
            background: MenuCategoryDishItem._soldOutBg,
            foreground: MenuCategoryDishItem._soldOutFg,
          )
        else
          _CategoryFooterButton(
            label: StoreMenuI18n.statusSoldOut.tr,
            background: MenuCategoryDishItem._soldOutBg,
            foreground: MenuCategoryDishItem._soldOutFg,
            loading: _markingSoldOut,
            onTap: _markSoldOut,
          ),
        SizedBox(width: 8.w),
        _CategoryFooterButton(
          label: StoreMenuI18n.takeOffShelfItem.tr,
          background: MenuCategoryDishItem._offShelfBg,
          foreground: MenuCategoryDishItem._offShelfFg,
          loading: _takingOff,
          onTap: _takeOffShelf,
        ),
      ],
    );
  }
}

class _CategoryFooterButton extends StatelessWidget {
  const _CategoryFooterButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(6.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: loading
              ? SizedBox(
                width: 14.w,
                height: 14.w,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: foreground,
                ),
              )
              : Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: foreground,
                  height: 1.1,
                ),
              ),
        ),
      ),
    );
  }
}

class _CategoryFooterChip extends StatelessWidget {
  const _CategoryFooterChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: foreground,
          height: 1.1,
        ),
      ),
    );
  }
}
