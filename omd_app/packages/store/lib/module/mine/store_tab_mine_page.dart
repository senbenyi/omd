import 'package:base/toast/nine_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/common/store_translations.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/common/user/go_user_controller.dart';
import 'package:store/common/user/go_personal_info_status_store.dart';
import 'package:store/module/login/store_login_i18n.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/store_tab_menu_controller.dart';
import 'package:store/module/order/store_order_history_page.dart';
import 'package:store/module/order/store_order_i18n.dart';
import 'package:store/module/store/store_i18n.dart';
import 'package:store/module/store/store_manage_page.dart';
import 'package:store/module/store/store_models.dart';
import 'package:store/module/store/store_status_chip.dart';
import 'package:store/module/store/store_tab_store_controller.dart';

class StoreTabMinePage extends StatefulWidget {
  const StoreTabMinePage({super.key});

  @override
  State<StoreTabMinePage> createState() => _StoreTabMinePageState();
}

class _StoreTabMinePageState extends State<StoreTabMinePage> {
  StoreTabMenuController? get _menu =>
      Get.isRegistered<StoreTabMenuController>()
          ? Get.find<StoreTabMenuController>()
          : null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _menu?.ensureLoaded();
    });
  }

  Future<void> _openStoreManage() async {
    final changed = await Get.to<bool>(() => const StoreManagePage());
    if (changed != true) return;

    if (Get.isRegistered<StoreTabStoreController>()) {
      await Get.find<StoreTabStoreController>().loadStores();
    }
    await _menu?.loadStores();
  }

  void _openHistoryOrders() {
    final menu = _menu;
    final store = menu?.selectedStore;
    if (store == null) {
      showAppToast(StoreMenuI18n.selectStore.tr);
      return;
    }
    Get.to(
      () => StoreOrderHistoryPage(
        storeId: store.id,
        storeName: store.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              StoreCommonI18n.tabMine.tr,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: StoreColors.primaryText,
              ),
            ),
            SizedBox(height: 24.h),
            Obx(() {
              final user = GoUserController.to.loginInfo.value;
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? StoreLoginI18n.notLoggedIn.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: StoreColors.primaryText,
                      ),
                    ),
                    if (GoPersonalInfoStatusStore.isLogin && user != null) ...[
                      SizedBox(height: 8.h),
                      if (user.phone != null && user.phone!.isNotEmpty)
                        Text(
                          user.phone!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: StoreColors.secondaryText,
                          ),
                        ),
                      SizedBox(height: 4.h),
                      Text(
                        'ID: ${user.displayUserId}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: StoreColors.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            SizedBox(height: 16.h),
            Obx(() {
              final menu = _menu;
              if (menu == null) {
                return _CurrentStoreCard(
                  loading: false,
                  store: null,
                );
              }

              final _ = menu.selectedStoreId.value;
              menu.stores.length;
              final selected = menu.selectedStore;
              return _CurrentStoreCard(
                loading: menu.isLoadingStores.value && selected == null,
                store: selected,
              );
            }),
            SizedBox(height: 12.h),
            _MineEntryTile(
              icon: Icons.history,
              title: StoreOrderI18n.historyOrders.tr,
              subtitle: StoreOrderI18n.historyOrdersHint.tr,
              onTap: _openHistoryOrders,
            ),
            SizedBox(height: 12.h),
            _MineEntryTile(
              icon: Icons.store_outlined,
              title: StoreStoreI18n.manageStores.tr,
              subtitle: StoreStoreI18n.manageStoresHint.tr,
              onTap: _openStoreManage,
            ),
            const Spacer(),
            SizedBox(
              height: 48.h,
              child: OutlinedButton(
                onPressed: GoUserController.to.logOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: StoreColors.tabSelected,
                  side: const BorderSide(color: StoreColors.tabSelected),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  StoreLoginI18n.logout.tr,
                  style: TextStyle(fontSize: 15.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentStoreCard extends StatelessWidget {
  const _CurrentStoreCard({
    required this.loading,
    required this.store,
  });

  final bool loading;
  final StoreModel? store;

  @override
  Widget build(BuildContext context) {
    final current = store;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StoreStoreI18n.currentStore.tr,
            style: TextStyle(
              fontSize: 14.sp,
              color: StoreColors.secondaryText,
            ),
          ),
          SizedBox(height: 10.h),
          if (loading)
            SizedBox(
              height: 24.h,
              width: 24.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          else if (current == null)
            Text(
              StoreStoreI18n.currentStoreEmpty.tr,
              style: TextStyle(
                fontSize: 15.sp,
                color: StoreColors.secondaryText,
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Text(
                    current.name,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: StoreColors.primaryText,
                    ),
                  ),
                ),
                StoreStatusChip(store: current),
              ],
            ),
        ],
      ),
    );
  }
}

class _MineEntryTile extends StatelessWidget {
  const _MineEntryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Icon(icon, size: 24.sp, color: StoreColors.tabSelected),
              SizedBox(width: 12.w),
              Expanded(
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
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: StoreColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 22.sp,
                color: StoreColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
