import 'package:base/log/nine_log.dart';
import 'package:common/http/go_http.dart';
import 'package:network/base/base_response.dart';
import 'package:store/module/login/store_auth_models.dart';
import 'package:store/module/order/store_order_models.dart';

class StoreOrderApi {
  StoreOrderApi._();

  static String listApi(int storeId) => '/stores/$storeId/orders';

  static String detailApi(int storeId, int orderId) => '/stores/$storeId/orders/$orderId';

  static String settleApi(int storeId, int orderId) => '/stores/$storeId/orders/$orderId/settle';

  static Future<StoreApiResponse<StoreOrderPageModel>> listOrders({
    required int storeId,
    String? status,
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await GoHttp.instance.get(
      url: listApi(storeId),
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        'page': page,
        'pageSize': pageSize,
      },
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parsePage(response);
  }

  static Future<StoreApiResponse<StoreOrderModel>> getOrder({
    required int storeId,
    required int orderId,
  }) async {
    final response = await GoHttp.instance.get(
      url: detailApi(storeId, orderId),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, StoreOrderModel.fromJson);
  }

  static Future<StoreApiResponse<StoreOrderModel>> settleOrder({
    required int storeId,
    required int orderId,
  }) async {
    final response = await GoHttp.instance.post(
      url: settleApi(storeId, orderId),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, StoreOrderModel.fromJson);
  }

  static StoreApiResponse<StoreOrderPageModel> _parsePage(NineBaseResponse response) {
    if (!_isBusinessSuccess(response)) {
      return StoreApiResponse(
        code: response.code.toString(),
        message: _failureMessage(response),
      );
    }
    final raw = response.data;
    if (raw is! Map) {
      return StoreApiResponse(code: '1001', message: '响应数据格式错误');
    }
    final listRaw = raw['list'];
    final meta = raw['meta'];
    final list = <StoreOrderListItemModel>[];
    if (listRaw is List) {
      for (final item in listRaw) {
        if (item is Map) {
          list.add(StoreOrderListItemModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    var total = list.length;
    if (meta is Map && meta['total'] != null) {
      total = _parseInt(meta['total']);
    }
    return StoreApiResponse(
      code: '0',
      message: response.message.isNotEmpty ? response.message : 'ok',
      data: StoreOrderPageModel(list: list, total: total),
    );
  }

  static StoreApiResponse<T> _parseObject<T>(
    NineBaseResponse response,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (!_isBusinessSuccess(response)) {
      return StoreApiResponse(
        code: response.code.toString(),
        message: _failureMessage(response),
      );
    }
    final raw = response.data;
    if (raw is! Map) {
      return StoreApiResponse(code: '1001', message: '响应数据格式错误');
    }
    try {
      return StoreApiResponse(
        code: '0',
        message: response.message.isNotEmpty ? response.message : 'ok',
        data: parser(Map<String, dynamic>.from(raw)),
      );
    } catch (e, stack) {
      NLog.e('StoreOrderApi 解析失败: $e\n$stack');
      return StoreApiResponse(code: '1001', message: '数据解析失败');
    }
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

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
