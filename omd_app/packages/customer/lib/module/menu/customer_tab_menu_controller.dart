import 'package:customer/common/customer_constants.dart';
import 'package:customer/module/api/customer_menu_api.dart';
import 'package:customer/module/menu/customer_menu_models.dart';
import 'package:customer/module/order/customer_cart_controller.dart';
import 'package:get/get.dart';

class CustomerTabMenuController extends GetxController {
  final items = <CustomerMenuItemModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await CustomerMenuApi.listItems(CustomerConstants.defaultStoreId);
      if (!response.isSuccess || response.data == null) {
        errorMessage.value = response.message.isNotEmpty ? response.message : '加载失败';
        items.clear();
        return;
      }
      items.assignAll(response.data!);
    } finally {
      isLoading.value = false;
    }
  }

  void addToCart(CustomerMenuItemModel item) {
    CustomerCartController.to.addMenuItem(
      id: item.id,
      name: item.name,
      price: item.price,
    );
  }
}
