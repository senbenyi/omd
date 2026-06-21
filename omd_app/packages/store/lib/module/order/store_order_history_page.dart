import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/order/store_order_i18n.dart';
import 'package:store/module/order/store_order_list_body.dart';

/// 历史订单：仅展示已结算订单。
class StoreOrderHistoryPage extends StatelessWidget {
  const StoreOrderHistoryPage({
    super.key,
    required this.storeId,
    this.storeName,
  });

  final int storeId;
  final String? storeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoreColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(StoreOrderI18n.historyOrders.tr),
      ),
      body: StoreOrderListBody(
        storeId: storeId,
        orderStatus: 'settled',
        showSettleAction: false,
        emptyText: StoreOrderI18n.emptyHistoryOrders.tr,
      ),
    );
  }
}
