import 'package:common/commonui/bottom_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/common/store_translations.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/bottom_tab/store_bottom_nav_logic.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/menu_widgets.dart';
import 'package:store/module/menu/store_tab_menu_controller.dart';
import 'package:store/module/order/store_order_i18n.dart';
import 'package:store/module/order/store_order_list_body.dart';
import 'package:store/module/store/store_tab_store_selector.dart';

class StoreTabOrderPage extends StatefulWidget {
  const StoreTabOrderPage({super.key});

  @override
  State<StoreTabOrderPage> createState() => _StoreTabOrderPageState();
}

class _StoreTabOrderPageState extends State<StoreTabOrderPage>
    with AutomaticKeepAliveClientMixin {
  static const _orderTabIndex = 0;

  final _listKey = GlobalKey<StoreOrderListBodyState>();
  Worker? _tabIndexWorker;
  Worker? _storeIdWorker;

  StoreTabMenuController get _menu => Get.find<StoreTabMenuController>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _menu.ensureLoaded();
      _reloadOrders();
    });

    if (Get.isRegistered<StoreBottomNavLogic>()) {
      final nav = Get.find<StoreBottomNavLogic>();
      _tabIndexWorker = ever(nav.selectedIndex, (index) {
        if (index == _orderTabIndex) {
          _reloadOrders();
        }
      });
    }

    _storeIdWorker = ever(_menu.selectedStoreId, (_) => _reloadOrders());
  }

  @override
  void dispose() {
    _tabIndexWorker?.dispose();
    _storeIdWorker?.dispose();
    super.dispose();
  }

  void _reloadOrders() {
    _listKey.currentState?.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ColoredBox(
      color: StoreColors.scaffoldBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MenuPageHeader(
              title: StoreCommonI18n.tabOrder.tr,
              storeSelector: const StoreTabStoreSelector(),
            ),
            Expanded(
              child: Obx(() {
                if (_menu.isLoadingStores.value && _menu.stores.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_menu.stores.isEmpty) {
                  return Center(
                    child: Text(
                      StoreMenuI18n.noStore.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: StoreColors.secondaryText,
                      ),
                    ),
                  );
                }

                final storeId = _menu.selectedStoreId.value;
                if (storeId == null) {
                  return Center(
                    child: Text(
                      StoreMenuI18n.selectStore.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: StoreColors.secondaryText,
                      ),
                    ),
                  );
                }

                return StoreOrderListBody(
                  key: _listKey,
                  storeId: storeId,
                  orderStatus: 'pending',
                  emptyText: StoreOrderI18n.emptyPendingOrders.tr,
                  bottomPadding: BottomArea.bottomBarHeigtOf(context) + 12,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
