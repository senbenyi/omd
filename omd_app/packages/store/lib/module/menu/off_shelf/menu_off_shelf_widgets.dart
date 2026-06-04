import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_price_utils.dart';

/// 已下架 Tab 菜品卡片（独立实现）。
class MenuOffShelfDishListTile extends StatelessWidget {
  const MenuOffShelfDishListTile({
    super.key,
    required this.name,
    required this.price,
    required this.categoryName,
    this.tags = const [],
    required this.offSaleLabel,
    required this.relistLabel,
    required this.onRelist,
    this.onTap,
  });

  static const _thumbBg = Color(0xFFE6F0FF);
  static const _accentBlue = Color(0xFF1890FF);
  static const _onShelfFg = Color(0xFF166534);
  static const _onShelfBg = Color(0xFFDCFCE7);
  static const _offShelfFg = Color(0xFF52525B);
  static const _offShelfBg = Color(0xFFF4F4F5);

  final String name;
  final int price;
  final String categoryName;
  final List<String> tags;
  final String offSaleLabel;
  final String relistLabel;
  final VoidCallback onRelist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initial =
        name.isNotEmpty ? String.fromCharCode(name.runes.first) : '?';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: _thumbBg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: _accentBlue,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: StoreColors.primaryText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      MenuPriceUtils.formatCents(price),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: StoreColors.tabSelected,
                      ),
                    ),
                    if (categoryName.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: StoreColors.secondaryText,
                        ),
                      ),
                    ],
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _offShelfBg,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        offSaleLabel,
                        style: TextStyle(fontSize: 10.sp, color: _offShelfFg),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Material(
                      color: _onShelfBg,
                      borderRadius: BorderRadius.circular(6.r),
                      child: InkWell(
                        onTap: onRelist,
                        borderRadius: BorderRadius.circular(6.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          child: Text(
                            relistLabel,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: _onShelfFg,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
