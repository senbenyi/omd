import 'package:base/toast/nine_toast.dart';
import 'package:customer/common/customer_translations.dart';
import 'package:customer/module/api/customer_api_response.dart';
import 'package:customer/module/api/customer_menu_api.dart';
import 'package:customer/module/menu/customer_menu_models.dart';
import 'package:customer/module/order/customer_cart_controller.dart';
import 'package:customer/module/order/customer_order_session_controller.dart';
import 'package:customer/module/order/customer_order_submit.dart';
import 'package:customer/module/store/customer_store_context_controller.dart';
import 'package:get/get.dart';

enum CustomerMenuSidebarKind { category, combo }

class CustomerMenuBrowseController extends GetxController {
  static CustomerMenuBrowseController get to =>
      Get.find<CustomerMenuBrowseController>();

  final sidebarKind = CustomerMenuSidebarKind.category.obs;
  final categories = <CustomerCategoryModel>[].obs;
  final selectedCategoryId = RxnInt();
  final allItems = <CustomerMenuItemModel>[].obs;
  final visibleItems = <CustomerMenuItemModel>[].obs;
  final combos = <CustomerComboModel>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  CustomerCartController get cart => CustomerCartController.to;
  CustomerOrderSessionController get session =>
      CustomerOrderSessionController.to;
  CustomerStoreContextController get storeCtx =>
      CustomerStoreContextController.to;

  int get storeId => storeCtx.storeId.value;

  @override
  void onInit() {
    super.onInit();
    reloadForStore();
  }

  Future<void> reloadForStore() async {
    cart.ensureStore(storeId);
    await storeCtx.refreshStoreFromApi();
    sidebarKind.value = CustomerMenuSidebarKind.category;
    selectedCategoryId.value = null;
    await session.refreshCurrentOrder();
    await loadMenu();
  }

  Future<void> loadMenu() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final results = await Future.wait([
        CustomerMenuApi.listCategories(storeId),
        CustomerMenuApi.listItems(storeId),
        CustomerMenuApi.listCombos(storeId),
      ]);

      final categoryResponse =
          results[0] as CustomerApiResponse<List<CustomerCategoryModel>>;
      final itemResponse =
          results[1] as CustomerApiResponse<List<CustomerMenuItemModel>>;
      final comboResponse =
          results[2] as CustomerApiResponse<List<CustomerComboModel>>;

      if (!categoryResponse.isSuccess ||
          !itemResponse.isSuccess ||
          !comboResponse.isSuccess) {
        errorMessage.value =
            categoryResponse.message.isNotEmpty
                ? categoryResponse.message
                : itemResponse.message.isNotEmpty
                ? itemResponse.message
                : comboResponse.message.isNotEmpty
                ? comboResponse.message
                : '加载失败';
        categories.clear();
        allItems.clear();
        visibleItems.clear();
        combos.clear();
        return;
      }

      categories.assignAll(categoryResponse.data ?? []);
      allItems.assignAll(itemResponse.data ?? []);
      combos.assignAll(comboResponse.data ?? []);

      if (sidebarKind.value == CustomerMenuSidebarKind.category) {
        _ensureCategorySelection();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(int categoryId) {
    sidebarKind.value = CustomerMenuSidebarKind.category;
    selectedCategoryId.value = categoryId;
    _applyCategoryFilter();
  }

  void selectComboTab() {
    sidebarKind.value = CustomerMenuSidebarKind.combo;
    selectedCategoryId.value = null;
    visibleItems.clear();
  }

  void addItemToCart(CustomerMenuItemModel item) {
    cart.ensureStore(storeId);
    cart.addMenuItem(id: item.id, name: item.name, price: item.price);
  }

  void addComboToCart(CustomerComboModel combo) {
    cart.ensureStore(storeId);
    cart.addCombo(id: combo.id, name: combo.name, price: combo.price);
  }

  Future<void> submitOrder() async {
    final currentStoreId = storeCtx.storeId.value;
    cart.ensureStore(currentStoreId);
    if (cart.lines.isEmpty || cart.totalQty <= 0) return;
    if (cart.storeId != currentStoreId) {
      showAppToast("提交订单失败");
      return;
    }
    if (!storeCtx.storeOpen.value) {
      showAppToast(CustomerCommonI18n.storeRestHint.tr);
      return;
    }
    isSubmitting.value = true;
    try {
      await submitCustomerOrder(storeId: currentStoreId);
    } finally {
      isSubmitting.value = false;
    }
  }

  void _ensureCategorySelection() {
    if (categories.isEmpty) {
      selectedCategoryId.value = null;
      visibleItems.clear();
      return;
    }
    final current = selectedCategoryId.value;
    if (current != null && categories.any((c) => c.id == current)) {
      _applyCategoryFilter();
      return;
    }
    selectCategory(categories.first.id);
  }

  void _applyCategoryFilter() {
    final categoryId = selectedCategoryId.value;
    if (categoryId == null) {
      visibleItems.clear();
      return;
    }
    visibleItems.assignAll(
      allItems.where((item) => item.categoryId == categoryId),
    );
  }
}
