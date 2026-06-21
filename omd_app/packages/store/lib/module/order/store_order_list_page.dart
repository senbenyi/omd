import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/order/store_order_i18n.dart';
import 'package:store/module/order/store_order_list_body.dart';

class StoreOrderListPage extends StatelessWidget {
  const StoreOrderListPage({
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
        title: Text(
          storeName ?? StoreOrderI18n.orderListTitle.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: StoreOrderListBody(
        storeId: storeId,
        orderStatus: 'pending',
        emptyText: StoreOrderI18n.emptyPendingOrders.tr,
      ),
    );
  }
}
