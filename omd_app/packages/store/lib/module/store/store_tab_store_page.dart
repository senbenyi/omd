import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/common/store_translations.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/store/store_detail_page.dart';
import 'package:store/module/store/store_form_page.dart';
import 'package:store/module/store/store_i18n.dart';
import 'package:store/module/store/store_models.dart';
import 'package:store/module/store/store_status_chip.dart';
import 'package:store/module/store/store_tab_store_controller.dart';

class StoreTabStorePage extends GetView<StoreTabStoreController> {
  const StoreTabStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StoreTabStoreBody();
  }
}

class _StoreTabStoreBody extends StatefulWidget {
  const _StoreTabStoreBody();

  @override
  State<_StoreTabStoreBody> createState() => _StoreTabStoreBodyState();
}

class _StoreTabStoreBodyState extends State<_StoreTabStoreBody>
    with AutomaticKeepAliveClientMixin {
  StoreTabStoreController get controller => Get.find<StoreTabStoreController>();

  @override
  bool get wantKeepAlive => true;

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
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      StoreCommonI18n.tabStore.tr,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        color: StoreColors.primaryText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _openAdd,
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: StoreColors.tabSelected,
                      size: 28.sp,
                    ),
                    tooltip: StoreStoreI18n.addStore.tr,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final storeList = controller.stores.toList(growable: false);
                final loading = controller.isLoading.value;

                if (loading && storeList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (storeList.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.loadStores,
                    color: StoreColors.tabSelected,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 120.h),
                        Center(
                          child: Text(
                            StoreStoreI18n.emptyStores.tr,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: StoreColors.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadStores,
                  color: StoreColors.tabSelected,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                    itemCount: storeList.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final store = storeList[index];
                      return _StoreListItem(
                        store: store,
                        onTap: () => _openDetail(store),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetail(StoreModel store) async {
    final changed = await Get.to<bool>(
      () => StoreDetailPage(storeId: store.id, initial: store),
    );
    if (changed == true) {
      controller.loadStores();
    }
  }

  Future<void> _openAdd() async {
    final created = await Get.to<bool>(() => const StoreFormPage());
    if (created == true) {
      controller.loadStores();
    }
  }
}

class _StoreListItem extends StatelessWidget {
  const _StoreListItem({required this.store, required this.onTap});

  final StoreModel store;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      store.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: StoreColors.primaryText,
                      ),
                    ),
                  ),
                  StoreStatusChip(store: store),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                store.address,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: StoreColors.secondaryText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${store.contactName} · ${store.phone}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: StoreColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
