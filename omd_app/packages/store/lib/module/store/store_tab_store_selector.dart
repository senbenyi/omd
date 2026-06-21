import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/module/menu/menu_core_widgets.dart';
import 'package:store/module/menu/menu_i18n.dart';
import 'package:store/module/menu/store_tab_menu_controller.dart';

/// 订单 / 菜单 Tab 右上角：店铺 icon + 名称，点击切换店铺。
class StoreTabStoreSelector extends StatelessWidget {
  const StoreTabStoreSelector({
    super.key,
    this.controllerTag,
  });

  final String? controllerTag;

  StoreTabMenuController get _controller {
    if (controllerTag != null) {
      return Get.find<StoreTabMenuController>(tag: controllerTag);
    }
    return Get.find<StoreTabMenuController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = _controller;
      if (controller.isStoreLocked) {
        final store = controller.selectedStore;
        if (store == null) return const SizedBox.shrink();
        return MenuStoreSelectorChip(label: store.name);
      }

      final storeList = controller.stores.toList(growable: false);
      if (storeList.isEmpty) {
        return const SizedBox.shrink();
      }

      final label =
          controller.selectedStore?.name ??
          StoreMenuI18n.selectStore.tr;
      final canSwitch = storeList.length > 1;

      return MenuStoreSelectorChip(
        label: label,
        showDropdown: canSwitch,
        onTap:
            canSwitch
                ? () => showStorePickerSheet(
                  context: context,
                  controller: controller,
                )
                : null,
      );
    });
  }
}

Future<void> showStorePickerSheet({
  required BuildContext context,
  required StoreTabMenuController controller,
}) async {
  final storeList = controller.stores.toList(growable: false);
  if (storeList.length <= 1) return;

  final selectedId = await showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: Text(
                StoreMenuI18n.selectStore.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: StoreColors.primaryText,
                ),
              ),
            ),
            for (final store in storeList)
              ListTile(
                leading: Icon(
                  Icons.storefront_outlined,
                  color: StoreColors.tabSelected,
                ),
                title: Text(
                  store.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing:
                    store.id == controller.selectedStoreId.value
                        ? Icon(
                          Icons.check_rounded,
                          color: StoreColors.tabSelected,
                        )
                        : null,
                onTap: () => Navigator.pop(sheetContext, store.id),
              ),
            SizedBox(height: 8.h),
          ],
        ),
      );
    },
  );

  if (selectedId != null) {
    await controller.selectStore(selectedId);
  }
}
