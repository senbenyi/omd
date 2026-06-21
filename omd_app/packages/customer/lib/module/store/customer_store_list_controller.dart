import 'package:customer/module/api/customer_store_api.dart';
import 'package:customer/module/store/customer_store_models.dart';
import 'package:get/get.dart';

class CustomerStoreListController extends GetxController {
  final stores = <CustomerStoreModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> loadStores() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await CustomerStoreApi.listStores();
      if (!response.isSuccess || response.data == null) {
        errorMessage.value = response.message.isNotEmpty ? response.message : '加载失败';
        stores.clear();
        return;
      }
      stores.assignAll(response.data!);
    } finally {
      isLoading.value = false;
    }
  }
}
