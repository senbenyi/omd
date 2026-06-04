import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/store/store_models.dart';
import 'package:store/module/store/store_status_helper.dart';

/// 按当前时间实时刷新营业状态标签。
class StoreStatusChip extends StatefulWidget {
  const StoreStatusChip({super.key, required this.store});

  final StoreModel store;

  @override
  State<StoreStatusChip> createState() => _StoreStatusChipState();
}

class _StoreStatusChipState extends State<StoreStatusChip> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = StoreStatusHelper.compute(widget.store);
    final label = _statusLabel(status);
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12.sp, color: color),
      ),
    );
  }

  String _statusLabel(String value) {
    for (final option in StoreStatusOption.options) {
      if (option.value == value) {
        return option.labelKey.tr;
      }
    }
    return value;
  }

  Color _statusColor(String value) {
    switch (value) {
      case 'open':
        return const Color(0xFF12B76A);
      case 'closed':
        return const Color(0xFFF04438);
      default:
        return StoreColors.secondaryText;
    }
  }
}

/// 详情页等场景使用的实时状态文案。
class StoreLiveStatusText extends StatefulWidget {
  const StoreLiveStatusText({super.key, required this.store});

  final StoreModel store;

  @override
  State<StoreLiveStatusText> createState() => _StoreLiveStatusTextState();
}

class _StoreLiveStatusTextState extends State<StoreLiveStatusText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = StoreStatusHelper.compute(widget.store);
    final label = _statusLabel(status);
    return Text(
      label,
      style: TextStyle(fontSize: 14.sp, color: StoreColors.primaryText),
    );
  }

  String _statusLabel(String value) {
    for (final option in StoreStatusOption.options) {
      if (option.value == value) {
        return option.labelKey.tr;
      }
    }
    return value;
  }
}
