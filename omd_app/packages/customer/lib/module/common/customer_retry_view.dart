import 'package:customer/common/customer_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomerRetryView extends StatelessWidget {
  const CustomerRetryView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            FilledButton(
              onPressed: onRetry,
              child: Text(CustomerCommonI18n.retry.tr),
            ),
          ],
        ),
      ),
    );
  }
}
