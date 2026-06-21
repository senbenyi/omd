import 'package:base/toast/nine_progress_hud.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_price_utils.dart';
import 'package:store/module/order/store_order_api.dart';
import 'package:store/module/order/store_order_i18n.dart';
import 'package:store/module/order/store_order_models.dart';
import 'package:store/module/order/store_order_status_chip.dart';

class StoreOrderDetailPage extends StatefulWidget {
  const StoreOrderDetailPage({
    super.key,
    required this.storeId,
    required this.orderId,
  });

  final int storeId;
  final int orderId;

  @override
  State<StoreOrderDetailPage> createState() => _StoreOrderDetailPageState();
}

class _StoreOrderDetailPageState extends State<StoreOrderDetailPage> {
  StoreOrderModel? _order;
  var _loading = true;
  var _settling = false;
  var _changed = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    NineProgressHud.showLoading();
    try {
      final response = await StoreOrderApi.getOrder(
        storeId: widget.storeId,
        orderId: widget.orderId,
      );
      if (!response.isSuccess || response.data == null) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreOrderI18n.loadFailed.tr,
        );
        return;
      }
      setState(() => _order = response.data);
    } finally {
      NineProgressHud.dismiss();
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _settle() async {
    final order = _order;
    if (order == null || !order.isPending || _settling) return;

    setState(() => _settling = true);
    NineProgressHud.showLoading();
    try {
      final response = await StoreOrderApi.settleOrder(
        storeId: widget.storeId,
        orderId: order.orderId,
      );
      if (!response.isSuccess || response.data == null) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreOrderI18n.loadFailed.tr,
        );
        return;
      }
      _changed = true;
      showAppToast(StoreOrderI18n.settleSuccess.tr);
      setState(() => _order = response.data);
    } finally {
      NineProgressHud.dismiss();
      if (mounted) setState(() => _settling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Get.back(result: _changed);
      },
      child: Scaffold(
        backgroundColor: StoreColors.scaffoldBackground,
        appBar: AppBar(
          title: Text(StoreOrderI18n.orderDetailTitle.tr),
        ),
        body: _loading && _order == null
            ? const Center(child: CircularProgressIndicator())
            : _order == null
            ? Center(
                child: Text(
                  StoreOrderI18n.loadFailed.tr,
                  style: TextStyle(fontSize: 14.sp, color: StoreColors.secondaryText),
                ),
              )
            : ListView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                children: [
                  _MetaCard(order: _order!),
                  SizedBox(height: 12.h),
                  Text(
                    StoreOrderI18n.orderItemsTitle.tr,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: StoreColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  for (final line in _order!.items) ...[
                    _LineCard(line: line),
                    SizedBox(height: 8.h),
                  ],
                ],
              ),
        bottomNavigationBar: _order != null && _order!.isPending
            ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                  child: FilledButton(
                    onPressed: _settling ? null : _settle,
                    style: FilledButton.styleFrom(
                      backgroundColor: StoreColors.tabSelected,
                      minimumSize: Size(double.infinity, 48.h),
                    ),
                    child: Text(
                      StoreOrderI18n.settleOrder.tr,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.order});

  final StoreOrderModel order;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${order.orderId}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: StoreColors.primaryText,
                  ),
                ),
              ),
              StoreOrderStatusChip(status: order.status),
            ],
          ),
          SizedBox(height: 12.h),
          _InfoRow(label: StoreOrderI18n.tableLabel.tr, value: '${order.tableNumber}'),
          _InfoRow(label: StoreOrderI18n.createdAtLabel.tr, value: order.createdAt),
          _InfoRow(
            label: StoreOrderI18n.totalLabel.tr,
            value: MenuPriceUtils.formatCents(order.totalAmount),
            valueColor: StoreColors.tabSelected,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 72.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 13.sp, color: StoreColors.secondaryText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: valueColor ?? StoreColors.primaryText,
                fontWeight: valueColor != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({required this.line});

  final StoreOrderLineModel line;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              line.name,
              style: TextStyle(fontSize: 15.sp, color: StoreColors.primaryText),
            ),
          ),
          Text('x${line.qty}', style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 12.w),
          Text(
            MenuPriceUtils.formatCents(line.subtotal),
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
