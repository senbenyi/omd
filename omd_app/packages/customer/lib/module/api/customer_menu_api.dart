import 'package:base/log/nine_log.dart';
import 'package:common/http/go_http.dart';
import 'package:customer/module/api/customer_api_response.dart';
import 'package:customer/module/menu/customer_menu_models.dart';
import 'package:network/base/base_response.dart';

class CustomerMenuApi {
  CustomerMenuApi._();

  static String itemsApi(int storeId) => '/customer/stores/$storeId/menu/items';

  static String combosApi(int storeId) => '/customer/stores/$storeId/menu/combos';

  static String ordersApi(int storeId) => '/customer/stores/$storeId/orders';

  static Future<CustomerApiResponse<List<CustomerMenuItemModel>>> listItems(
    int storeId,
  ) async {
    final response = await GoHttp.instance.get(
      url: itemsApi(storeId),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseList(response, CustomerMenuItemModel.fromJson);
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
    return _parseList(response, CustomerComboModel.fromJson);
  }

  static Future<CustomerApiResponse<CustomerOrderResultModel>> submitOrder({
    required int storeId,
    required int tableNumber,
    required List<Map<String, dynamic>> items,
    String? remark,
  }) async {
    final response = await GoHttp.instance.post(
      url: ordersApi(storeId),
      params: {
        'tableNumber': tableNumber,
        if (remark != null && remark.isNotEmpty) 'remark': remark,
        'items': items,
      },
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, CustomerOrderResultModel.fromJson);
  }

  static CustomerApiResponse<T> _parseObject<T>(
    NineBaseResponse response,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (!_isBusinessSuccess(response)) {
      return CustomerApiResponse(
        code: response.code.toString(),
        message: _failureMessage(response),
      );
    }
    final raw = response.data;
    if (raw is! Map) {
      return CustomerApiResponse(code: '1001', message: '响应数据格式错误');
    }
    try {
      return CustomerApiResponse(
        code: '0',
        message: response.message.isNotEmpty ? response.message : 'ok',
        data: parser(Map<String, dynamic>.from(raw)),
      );
    } catch (e, stack) {
      NLog.e('CustomerMenuApi 解析对象失败: $e\n$stack');
      return CustomerApiResponse(code: '1001', message: '数据解析失败');
    }
  }

  static CustomerApiResponse<List<T>> _parseList<T>(
    NineBaseResponse response,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (!_isBusinessSuccess(response)) {
      return CustomerApiResponse(
        code: response.code.toString(),
        message: _failureMessage(response),
      );
    }
    final raw = response.data;
    final List<dynamic> items;
    if (raw is List) {
      items = raw;
    } else if (raw is Map && raw['list'] is List) {
      items = raw['list'] as List<dynamic>;
    } else {
      return CustomerApiResponse(code: '1001', message: '响应数据格式错误');
    }

    final list = <T>[];
    for (final item in items) {
      if (item is! Map) continue;
      try {
        list.add(parser(Map<String, dynamic>.from(item)));
      } catch (e, stack) {
        NLog.e('CustomerMenuApi 解析列表项失败: $e item=$item\n$stack');
      }
    }
    return CustomerApiResponse(
      code: '0',
      message: response.message.isNotEmpty ? response.message : 'ok',
      data: list,
    );
  }

  static bool _isBusinessSuccess(NineBaseResponse response) {
    if (response.error != null) return false;
    if (response.statusCode >= 400) return false;
    final code = response.code.toString();
    return code == '0' || code == '200';
  }

  static String _failureMessage(NineBaseResponse response) {
    if (response.message.isNotEmpty) return response.message;
    if (response.statusMessage.isNotEmpty) return response.statusMessage;
    return '请求失败';
  }
}
