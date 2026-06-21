import 'package:common/http/go_http.dart';
import 'package:customer/module/api/customer_api_parser.dart';
import 'package:customer/module/api/customer_api_response.dart';
import 'package:customer/module/menu/customer_menu_models.dart';

class CustomerMenuApi {
  CustomerMenuApi._();

  static String categoriesApi(int storeId) => '/customer/stores/$storeId/menu/categories';

  static String itemsApi(int storeId) => '/customer/stores/$storeId/menu/items';

  static String combosApi(int storeId) => '/customer/stores/$storeId/menu/combos';

  static String currentOrderApi(int storeId) => '/customer/stores/$storeId/orders/current';

  static String ordersApi(int storeId) => '/customer/stores/$storeId/orders';

  static Future<CustomerApiResponse<List<CustomerCategoryModel>>> listCategories(
    int storeId,
  ) async {
    final response = await GoHttp.instance.get(
      url: categoriesApi(storeId),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return CustomerApiParser.parseList(response, CustomerCategoryModel.fromJson);
  }

  static Future<CustomerApiResponse<List<CustomerMenuItemModel>>> listItems(
    int storeId,
  ) async {
    final response = await GoHttp.instance.get(
      url: itemsApi(storeId),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return CustomerApiParser.parseList(response, CustomerMenuItemModel.fromJson);
  }

  static Future<CustomerApiResponse<List<CustomerComboModel>>> listCombos(
    int storeId,
  ) async {
    final response = await GoHttp.instance.get(
      url: combosApi(storeId),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return CustomerApiParser.parseList(response, CustomerComboModel.fromJson);
  }

  static Future<CustomerApiResponse<CustomerOrderResultModel>> submitOrder({
    required int storeId,
    required int tableNumber,
    required List<Map<String, dynamic>> items,
    String? remark,
    int? orderId,
  }) async {
    final response = await GoHttp.instance.post(
      url: ordersApi(storeId),
      params: {
        'storeId': storeId,
        'tableNumber': tableNumber,
        if (remark != null && remark.isNotEmpty) 'remark': remark,
        if (orderId != null && orderId > 0) 'orderId': orderId,
        'items': items,
      },
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return CustomerApiParser.parseObject(response, CustomerOrderResultModel.fromJson);
  }

  static Future<CustomerApiResponse<CustomerOrderResultModel?>> getCurrentOrder({
    required int storeId,
    required int tableNumber,
  }) async {
    final response = await GoHttp.instance.get(
      url: currentOrderApi(storeId),
      queryParameters: {'tableNumber': tableNumber},
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return CustomerApiParser.parseNullableObject(response, CustomerOrderResultModel.fromJson);
  }
}
