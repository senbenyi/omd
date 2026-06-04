import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_core_widgets.dart';

/// 表单双项开关（如 在售/售罄、上架/下架）。
class MenuFormSegmentToggle extends StatelessWidget {
  const MenuFormSegmentToggle({
    super.key,
    required this.value,
    required this.leftLabel,
    required this.rightLabel,
    required this.onChanged,
  });

  /// true 表示选中右侧选项。
  final bool value;
  final String leftLabel;
  final String rightLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      decoration: BoxDecoration(
        color: MenuFormFieldStyle.fillColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(2.w),
      child: Row(
        children: [
          Expanded(
            child: _SegmentOption(
              label: leftLabel,
              selected: !value,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _SegmentOption(
              label: rightLabel,
              selected: value,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentOption extends StatelessWidget {
  const _SegmentOption({
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
      borderRadius: BorderRadius.circular(6.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? StoreColors.tabSelected : StoreColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}
/// 表单页底部主操作栏（含安全区）。
class MenuFormBottomSaveBar extends StatelessWidget {
  const MenuFormBottomSaveBar({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: MenuLayout.divider)),
        boxShadow: [
          BoxShadow(
            color: MenuLayout.cardShadow,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          child: SizedBox(
            width: double.infinity,
            height: 42.h,
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: StoreColors.tabSelected,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 表单分组白卡片。
class MenuFormCard extends StatelessWidget {
  const MenuFormCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: MenuLayout.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}


/// 表单内嵌输入框样式。
abstract final class MenuFormFieldStyle {
  static const fillColor = Color(0xFFF5F7FB);

  static InputDecoration decoration({
    String? hintText,
    String? prefixText,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      suffixText: suffixText,
      filled: true,
      fillColor: fillColor,
      hintStyle: TextStyle(fontSize: 14.sp, color: StoreColors.secondaryText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
          color: StoreColors.tabSelected.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      isDense: true,
    );
  }
}

/// 表单卡片内：左侧标题、右侧输入（单行）。
class MenuFormInlineField extends StatelessWidget {
  const MenuFormInlineField({
    super.key,
    required this.label,
    required this.child,
    this.labelWidth,
    this.showDivider = true,
  });

  final String label;
  final Widget child;
  final double? labelWidth;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: labelWidth ?? 80.w,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: StoreColors.primaryText,
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, color: MenuLayout.divider.withValues(alpha: 0.85)),
      ],
    );
  }
}

/// 内联输入框（右侧），无填充背景。
class MenuFormInlineInput extends StatelessWidget {
  const MenuFormInlineInput({
    super.key,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.textAlign = TextAlign.end,
    this.prefixText,
    this.suffix,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final String? prefixText;
  final Widget? suffix;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      maxLines: maxLines,
      style: TextStyle(fontSize: 14.sp, color: StoreColors.primaryText),
      decoration: InputDecoration(
        hintText: hintText,
        prefixText: prefixText,
        suffix: suffix,
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 2.w),
        hintStyle: TextStyle(fontSize: 13.sp, color: StoreColors.secondaryText),
      ),
    );
  }
}

/// 表单卡片内带标签的输入行。
class MenuFormFieldRow extends StatelessWidget {
  const MenuFormFieldRow({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: StoreColors.secondaryText,
          ),
        ),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }
}

Future<String?> showMenuNameInputDialog({
  required BuildContext context,
  required String title,
  required String hint,
  required String cancelLabel,
  required String confirmLabel,
}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed:
                () => Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
}

