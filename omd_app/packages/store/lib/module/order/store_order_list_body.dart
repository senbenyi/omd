import 'package:base/toast/nine_progress_hud.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_price_utils.dart';
import 'package:store/module/order/store_order_api.dart';
import 'package:store/module/order/store_order_detail_page.dart';
import 'package:store/module/order/store_order_i18n.dart';
import 'package:store/module/order/store_order_models.dart';
import 'package:store/module/order/store_order_status_chip.dart';

class StoreOrderListBody extends StatefulWidget {
  const StoreOrderListBody({
    super.key,
    required this.storeId,
    this.bottomPadding = 24,
    this.orderStatus,
    this.showSettleAction = true,
    this.emptyText,
  });

  final int storeId;
  final double bottomPadding;
  /// `pending` 进行中；`settled` 已结算。null 表示不过滤。
  final String? orderStatus;
  final bool showSettleAction;
  final String? emptyText;

  @override
  State<StoreOrderListBody> createState() => StoreOrderListBodyState();
}

class StoreOrderListBodyState extends State<StoreOrderListBody> {
  final _orders = <StoreOrderListItemModel>[];
  var _loading = true;
  var _settlingId = 0;

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  @override
  void didUpdateWidget(covariant StoreOrderListBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storeId != widget.storeId ||
        oldWidget.orderStatus != widget.orderStatus) {
      loadOrders();
    }
  }

  Future<void> loadOrders() async {
    setState(() => _loading = true);
    try {
      final response = await StoreOrderApi.listOrders(
        storeId: widget.storeId,
        status: widget.orderStatus,
      );
      if (!response.isSuccess || response.data == null) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreOrderI18n.loadFailed.tr,
        );
        return;
      }
      setState(() {
        _orders
          ..clear()
          ..addAll(response.data!.list);
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _settleOrder(StoreOrderListItemModel order) async {
    if (!order.isPending || _settlingId > 0) return;

    setState(() => _settlingId = order.orderId);
    NineProgressHud.showLoading();
    try {
      final response = await StoreOrderApi.settleOrder(
        storeId: widget.storeId,
        orderId: order.orderId,
      );
      if (!response.isSuccess) {
        showAppToast(
          response.message.isNotEmpty
              ? response.message
              : StoreOrderI18n.loadFailed.tr,
        );
        return;
      }
      showAppToast(StoreOrderI18n.settleSuccess.tr);
      await loadOrders();
    } finally {
      NineProgressHud.dismiss();
      if (mounted) setState(() => _settlingId = 0);
    }
  }

  Future<void> _openDetail(StoreOrderListItemModel order) async {
    final changed = await Get.to<bool>(
      () => StoreOrderDetailPage(
        storeId: widget.storeId,
        orderId: order.orderId,
      ),
    );
    if (changed == true) {
      await loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadOrders,
        color: StoreColors.tabSelected,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 120.h),
            Center(
              child: Text(
                widget.emptyText ?? StoreOrderI18n.emptyOrders.tr,
                style: TextStyle(fontSize: 14.sp, color: StoreColors.secondaryText),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadOrders,
      color: StoreColors.tabSelected,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, widget.bottomPadding.h),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _OrderListItem(
            order: order,
            settling: _settlingId == order.orderId,
            showSettleAction: widget.showSettleAction,
            onTap: () => _openDetail(order),
            onSettle: () => _settleOrder(order),
          );
        },
      ),
    );
  }
}

class _OrderListItem extends StatelessWidget {
  const _OrderListItem({
    required this.order,
    required this.settling,
    required this.showSettleAction,
    required this.onTap,
    required this.onSettle,
  });

  final StoreOrderListItemModel order;
  final bool settling;
  final bool showSettleAction;
  final VoidCallback onTap;
  final VoidCallback onSettle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${StoreOrderI18n.tableLabel.tr} ${order.tableNumber} · #${order.orderId}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: StoreColors.primaryText,
                          ),
                        ),
                      ),
                      StoreOrderStatusChip(status: order.status),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${StoreOrderI18n.createdAtLabel.tr} ${order.createdAt}',
                    style: TextStyle(fontSize: 13.sp, color: StoreColors.secondaryText),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${StoreOrderI18n.itemCountLabel.tr} ${order.itemCount}',
                    style: TextStyle(fontSize: 13.sp, color: StoreColors.secondaryText),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Text(
                  MenuPriceUtils.formatCents(order.totalAmount),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: StoreColors.tabSelected,
                  ),
                ),
                const Spacer(),
                if (showSettleAction && order.isPending)
                  FilledButton(
                    onPressed: settling ? null : onSettle,
                    style: FilledButton.styleFrom(
                      backgroundColor: StoreColors.tabSelected,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    child: Text(
                      StoreOrderI18n.settleOrder.tr,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
