import 'package:get/get.dart';
import 'package:customer/module/bottom_tab/customer_bottom_tab_config.dart';

class CustomerBottomNavLogic extends GetxController {
  final selectedIndex = 0.obs;
  final List<CustomerTabConfig> configList = CustomerBottomTabConfig.tabs;

  void changeIndex(int index) {
    if (index < 0 || index >= configList.length) {
      return;
    }
    selectedIndex.value = index;
  }
}
