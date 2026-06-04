import 'package:get/get.dart';
import 'package:store/module/bottom_tab/store_bottom_tab_config.dart';

class StoreBottomNavLogic extends GetxController {
  final selectedIndex = 0.obs;
  final List<StoreTabConfig> configList = StoreBottomTabConfig.tabs;

  void changeIndex(int index) {
    if (index < 0 || index >= configList.length) {
      return;
    }
    selectedIndex.value = index;
  }
}
