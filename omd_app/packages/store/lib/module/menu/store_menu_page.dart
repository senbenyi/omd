import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store/common/store_translations.dart';
import 'package:store/module/menu/store_tab_menu_controller.dart';
import 'package:store/module/menu/store_tab_menu_page.dart';

/// 从店铺详情 push 进入的单店菜单页。
class StoreMenuPage extends StatefulWidget {
  const StoreMenuPage({
    super.key,
    required this.storeId,
    this.storeName,
  });

  final int storeId;
  final String? storeName;

  @override
  State<StoreMenuPage> createState() => _StoreMenuPageState();
}

class _StoreMenuPageState extends State<StoreMenuPage> {
  late final String _controllerTag;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'store_menu_${widget.storeId}';
    Get.put(
      StoreTabMenuController(fixedStoreId: widget.storeId),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<StoreTabMenuController>(tag: _controllerTag)) {
      Get.delete<StoreTabMenuController>(tag: _controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.storeName ?? StoreCommonI18n.tabMenu.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: MenuPageBody(
        controllerTag: _controllerTag,
        showTabHeader: false,
      ),
    );
  }
}
