import 'package:customer/common/customer_translations.dart';
import 'package:customer/module/a_color/customer_colors.dart';
import 'package:customer/module/common/customer_menu_shell.dart';
import 'package:customer/module/common/customer_retry_view.dart';
import 'package:customer/module/store/customer_store_context_controller.dart';
import 'package:customer/module/store/customer_store_status_chip.dart';
import 'package:customer/module/store/customer_store_list_controller.dart';
import 'package:customer/module/store/customer_store_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomerStoreListPage extends StatefulWidget {
  const CustomerStoreListPage({super.key});

  @override
  State<CustomerStoreListPage> createState() => _CustomerStoreListPageState();
}

class _CustomerStoreListPageState extends State<CustomerStoreListPage> {
  late final CustomerStoreListController _controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<CustomerStoreListController>()) {
      Get.delete<CustomerStoreListController>();
    }
    _controller = Get.put(CustomerStoreListController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.loadStores();
    });
  }

  @override
  void dispose() {
    if (Get.isRegistered<CustomerStoreListController>()) {
      Get.delete<CustomerStoreListController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeCtx = CustomerStoreContextController.to;

    return CustomerMenuShell(
      title: CustomerCommonI18n.selectStore.tr,
      leading: const BackButton(),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.stores.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_controller.errorMessage.value.isNotEmpty && _controller.stores.isEmpty) {
          return CustomerRetryView(
            message: _controller.errorMessage.value,
            onRetry: _controller.loadStores,
          );
        }
        if (_controller.stores.isEmpty) {
          return Center(
            child: Text(
              CustomerCommonI18n.emptyStores.tr,
              style: TextStyle(color: CustomerColors.secondaryText, fontSize: 14.sp),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.loadStores,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
            itemCount: _controller.stores.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final store = _controller.stores[index];
              final selected = store.id == storeCtx.storeId.value;
              return _StoreListItem(
                store: store,
                selected: selected,
                onTap: () async {
                  await storeCtx.switchStore(store);
                  Get.back();
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _StoreListItem extends StatelessWidget {
  const _StoreListItem({
    required this.store,
    required this.selected,
    required this.onTap,
  });

  final CustomerStoreModel store;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? CustomerColors.tabSelected.withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: CustomerColors.primaryText,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        CustomerStoreStatusChip(store: store),
                      ],
                    ),
                    if (store.address.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        store.address,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: CustomerColors.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected) ...[
                SizedBox(width: 8.w),
                Icon(Icons.check_circle, color: CustomerColors.tabSelected, size: 22.sp),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
