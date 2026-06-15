import 'package:customer/module/bottom_tab/customer_bottom_tab_config.dart';
import 'package:customer/module/bottom_tab/customer_bottom_tab_type.dart';
import 'package:get/get.dart';

class CustomerBottomNavLogic extends GetxController {
  static CustomerBottomNavLogic get to => Get.find<CustomerBottomNavLogic>();

  final selectedIndex = 0.obs;
  final List<CustomerTabConfig> configList = CustomerBottomTabConfig.tabs;

  int indexOf(CustomerBottomTabType type) {
    return configList.indexWhere((config) => config.type == type);
  }

  void changeIndex(int index) {
    if (index < 0 || index >= configList.length) {
      return;
    }
    selectedIndex.value = index;
  }
}
