import 'package:customer/common/customer_constants.dart';
import 'package:customer/module/api/customer_menu_api.dart';
import 'package:customer/module/menu/customer_menu_models.dart';
import 'package:customer/module/order/customer_cart_controller.dart';
import 'package:get/get.dart';

class CustomerTabComboController extends GetxController {
  final combos = <CustomerComboModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCombos();
  }

  Future<void> loadCombos() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await CustomerMenuApi.listCombos(CustomerConstants.defaultStoreId);
      if (!response.isSuccess || response.data == null) {
        errorMessage.value = response.message.isNotEmpty ? response.message : '加载失败';
        combos.clear();
        return;
      }
      combos.assignAll(response.data!);
    } finally {
      isLoading.value = false;
    }
  }

  void addToCart(CustomerComboModel combo) {
    CustomerCartController.to.addCombo(
      id: combo.id,
      name: combo.name,
      price: combo.price,
    );
  }
}
