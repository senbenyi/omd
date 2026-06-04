import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/store/store_i18n.dart';

/// 底部滚轮时间选择器。
Future<TimeOfDay?> showStoreTimePickerSheet(
  BuildContext context, {
  required TimeOfDay initialTime,
  required String title,
}) {
  var selected = initialTime;

  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: Text(
                      StoreStoreI18n.timePickerCancel.tr,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: StoreColors.secondaryText,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: StoreColors.primaryText,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext, selected),
                    child: Text(
                      StoreStoreI18n.timePickerConfirm.tr,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: StoreColors.tabSelected,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220.h,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: DateTime(
                  2020,
                  1,
                  1,
                  initialTime.hour,
                  initialTime.minute,
                ),
                onDateTimeChanged: (dateTime) {
                  selected = TimeOfDay(
                    hour: dateTime.hour,
                    minute: dateTime.minute,
                  );
                },
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      );
    },
  );
}
