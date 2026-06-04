import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_price_utils.dart';
import 'package:store/module/menu/menu_core_widgets.dart';

/// 套餐详情顶栏：原价划线 + 套餐价红色突出。
class MenuComboDetailHeader extends StatelessWidget {
  const MenuComboDetailHeader({
    super.key,
    required this.comboName,
    required this.itemsTotalCents,
    required this.comboPriceCents,
    required this.onEdit,
  });

  final String comboName;
  final int itemsTotalCents;
  final int comboPriceCents;
  final VoidCallback onEdit;

  static const _saleRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final hasDiscount = itemsTotalCents > comboPriceCents && comboPriceCents > 0;
    final savings = itemsTotalCents - comboPriceCents;

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: MenuLayout.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  comboName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: StoreColors.primaryText,
                  ),
                ),
              ),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: StoreColors.tabSelected,
                ),
                child: Text(
                  StoreMenuI18n.editCombo.tr,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StoreMenuI18n.comboOriginalPriceLabel.tr,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: StoreColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      MenuPriceUtils.formatCents(itemsTotalCents),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: StoreColors.secondaryText,
                        decoration:
                            hasDiscount
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                        decorationColor: StoreColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    StoreMenuI18n.comboSalePriceLabel.tr,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: StoreColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    MenuPriceUtils.formatCents(comboPriceCents),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: _saleRed,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (hasDiscount) ...[
            SizedBox(height: 6.h),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _saleRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${StoreMenuI18n.comboSavePrefix.tr}${MenuPriceUtils.formatCents(savings)}',
                  style: TextStyle(fontSize: 11.sp, color: _saleRed),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 套餐详情内紧凑菜品行。
class MenuComboDishListTile extends StatelessWidget {
  const MenuComboDishListTile({
    super.key,
    required this.name,
    required this.unitPriceCents,
    required this.qty,
    required this.lineTotalCents,
  });

  final String name;
  final int unitPriceCents;
  final int qty;
  final int lineTotalCents;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: MenuLayout.divider.withValues(alpha: 0.6)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Row(
        children: [
          MenuDishThumbnail(name: name, size: 40),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: StoreColors.primaryText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '$qty${StoreMenuI18n.minQtyUnit.tr} · ${MenuPriceUtils.formatCents(unitPriceCents)}/${StoreMenuI18n.minQtyUnit.tr}',
                  style: TextStyle(fontSize: 11.sp, color: StoreColors.secondaryText),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            MenuPriceUtils.formatCents(lineTotalCents),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: StoreColors.tabSelected,
            ),
          ),
        ],
      ),
    );
  }
}
