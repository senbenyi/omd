import 'package:base/toast/nine_progress_hud.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/store_menu_page.dart';
import 'package:store/module/store/store_api.dart';
import 'package:store/module/store/store_form_page.dart';
import 'package:store/module/store/store_i18n.dart';
import 'package:store/module/store/store_models.dart';
import 'package:store/module/store/store_status_chip.dart';
import 'package:store/module/store/store_time_utils.dart';

class StoreDetailPage extends StatefulWidget {
  const StoreDetailPage({
    super.key,
    required this.storeId,
    this.initial,
  });

  final int storeId;
  final StoreModel? initial;

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  StoreModel? _store;
  var _loading = true;
  var _changed = false;

  @override
  void initState() {
    super.initState();
    _store = widget.initial;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    NineProgressHud.showLoading();
    try {
      final response = await StoreApi.getStoreDetail(widget.storeId);
      if (!response.isSuccess || response.data == null) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreStoreI18n.loadFailed.tr,
        );
        return;
      }
      setState(() => _store = response.data);
    } finally {
      NineProgressHud.dismiss();
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openEdit() async {
    final store = _store;
    if (store == null) return;

    final updated = await Get.to<bool>(() => StoreFormPage(store: store));
    if (updated == true) {
      _changed = true;
      await _loadDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.back(result: _changed);
        }
      },
      child: Scaffold(
      backgroundColor: StoreColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(StoreStoreI18n.storeDetail.tr),
        actions: [
          if (_store != null)
            TextButton(
              onPressed: _openEdit,
              child: Text(
                StoreStoreI18n.editStore.tr,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: StoreColors.tabSelected,
                ),
              ),
            ),
        ],
      ),
      body:
          _loading && _store == null
              ? const Center(child: CircularProgressIndicator())
              : _store == null
              ? Center(
                child: Text(
                  StoreStoreI18n.loadFailed.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: StoreColors.secondaryText,
                  ),
                ),
              )
              : ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _InfoCard(
                    title: _store!.name,
                    children: [
                      _InfoRow(
                        label: StoreStoreI18n.statusLabel.tr,
                        valueWidget: StoreLiveStatusText(store: _store!),
                      ),
                      _InfoRow(
                        label: StoreStoreI18n.addressHint.tr,
                        value: _store!.address,
                      ),
                      _InfoRow(
                        label: StoreStoreI18n.phoneHint.tr,
                        value: _store!.phone,
                      ),
                      _InfoRow(
                        label: StoreStoreI18n.contactHint.tr,
                        value: _store!.contactName,
                      ),
                      _InfoRow(
                        label: StoreStoreI18n.businessHours.tr,
                        value: _businessHoursText(_store!.businessHours),
                      ),
                      _InfoRow(
                        label: StoreStoreI18n.closedWeekdays.tr,
                        value: _closedWeekdaysText(_store!.closedWeekdays),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _InfoCard(
                    title: StoreStoreI18n.serviceInfo.tr,
                    children: [
                      _InfoRow(
                        label: StoreStoreI18n.serviceExpire.tr,
                        value: _store!.serviceInfo.serviceExpireAt,
                      ),
                      _InfoRow(
                        label: StoreStoreI18n.vipLevel.tr,
                        value: '${_store!.serviceInfo.vipLevel}',
                      ),
                      if (_store!.serviceInfo.referrerId != null &&
                          _store!.serviceInfo.referrerId!.isNotEmpty)
                        _InfoRow(
                          label: StoreStoreI18n.referrerId.tr,
                          value: _store!.serviceInfo.referrerId!,
                        ),
                      _InfoRow(
                        label: StoreStoreI18n.additionalPeriod.tr,
                        value: '${_store!.serviceInfo.additionalPeriod}',
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _InfoCard(
                    title: StoreStoreI18n.manageMenu.tr,
                    children: [
                      _MenuEntryRow(
                        hint: StoreStoreI18n.manageMenuHint.tr,
                        onTap: () {
                          Get.to(
                            () => StoreMenuPage(
                              storeId: _store!.id,
                              storeName: _store!.name,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  String _businessHoursText(StoreBusinessHours hours) {
    if (hours.isOpen24Hours) {
      return StoreStoreI18n.open24Hours.tr;
    }
    return '${StoreTimeOfDayMs.format(hours.openTime)} - ${StoreTimeOfDayMs.format(hours.closeTime)}';
  }

  String _closedWeekdaysText(List<int> weekdays) {
    if (weekdays.isEmpty) {
      return StoreStoreI18n.noneSelected.tr;
    }
    final labels =
        weekdays
            .map((day) => StoreWeekdayOption.labelFor(day).tr)
            .toList();
    return labels.join('、');
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: StoreColors.primaryText,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }
}

class _MenuEntryRow extends StatelessWidget {
  const _MenuEntryRow({
    required this.hint,
    required this.onTap,
  });

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hint,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: StoreColors.primaryText,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: StoreColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
  }) : assert(value != null || valueWidget != null);

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: StoreColors.secondaryText,
              ),
            ),
          ),
          Expanded(
            child:
                valueWidget ??
                Text(
                  value ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: StoreColors.primaryText,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
