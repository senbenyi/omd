import 'package:customer/common/customer_constants.dart';
import 'package:customer/common/customer_price_utils.dart';
import 'package:customer/module/a_color/customer_colors.dart';
import 'package:customer/module/order/customer_cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomerTableHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomerTableHeader({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => Size.fromHeight(44.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
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
    );
  }
}

class CustomerCartBadge extends StatelessWidget {
  const CustomerCartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CustomerCartController.to;
    return Obx(() {
      if (cart.totalQty <= 0) return const SizedBox.shrink();
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: CustomerColors.tabSelected,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          '${cart.totalQty}',
          style: TextStyle(color: Colors.white, fontSize: 12.sp),
        ),
      );
    });
  }
}

class CustomerAddButton extends StatelessWidget {
  const CustomerAddButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(Icons.add_circle, color: CustomerColors.tabSelected, size: 28.sp),
    );
  }
}

/// 菜单/套餐列表上的加减控件，已选时展示份数。
class CustomerQtyStepper extends StatelessWidget {
  const CustomerQtyStepper({
    super.key,
    required this.type,
    required this.id,
    required this.onAdd,
  });

  final String type;
  final int id;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cart = CustomerCartController.to;
    return Obx(() {
      final qty = cart.qtyOf(type: type, id: id);
      if (qty <= 0) {
        return CustomerAddButton(onPressed: onAdd);
      }
      final key = '$type-$id';
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepIconButton(
            icon: Icons.remove,
            onPressed: () => cart.decreaseQty(key),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              '$qty',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: CustomerColors.primaryText,
              ),
            ),
          ),
          _StepIconButton(
            icon: Icons.add,
            onPressed: () => cart.increaseQty(key),
          ),
        ],
      );
    });
  }
}

class _StepIconButton extends StatelessWidget {
  const _StepIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: CustomerColors.tabSelected.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(icon, size: 16.sp, color: CustomerColors.tabSelected),
      ),
    );
  }
}

class CustomerPriceText extends StatelessWidget {
  const CustomerPriceText({super.key, required this.cents, this.fontSize});

  final int cents;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      CustomerPriceUtils.formatCents(cents),
      style: TextStyle(
        fontSize: fontSize ?? 15.sp,
        color: CustomerColors.tabSelected,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
