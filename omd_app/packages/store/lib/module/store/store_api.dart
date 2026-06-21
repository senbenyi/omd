import 'package:base/log/nine_log.dart';
import 'package:common/http/go_http.dart';
import 'package:network/base/base_response.dart';
import 'package:store/module/login/store_auth_models.dart';
import 'package:store/module/store/store_models.dart';

/// 门店接口，与 [omd_api.openapi.yaml] 对齐。
class StoreApi {
  StoreApi._();

  static const String listApi = '/stores';
  static const String saveApi = '/stores/save';

  static String detailApi(int storeId) => '/stores/$storeId';

  static Future<StoreApiResponse<List<StoreModel>>> listStores() async {
    final response = await GoHttp.instance.get(
      url: listApi,
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseList(response, StoreModel.fromJson);
  }

  static Future<StoreApiResponse<StoreModel>> getStoreDetail(int storeId) async {
    final response = await GoHttp.instance.get(
      url: detailApi(storeId),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, StoreModel.fromJson);
  }

  static Future<StoreApiResponse<StoreModel>> saveStore(
    SaveStoreRequest request,
  ) async {
    final response = await GoHttp.instance.post(
      url: saveApi,
      params: request.toJson(),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseObject(response, StoreModel.fromJson);
  }

  static Future<StoreApiResponse<void>> deleteStore(int storeId) async {
    final response = await GoHttp.instance.delete(
      url: detailApi(storeId),
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    if (!_isBusinessSuccess(response)) {
      return StoreApiResponse.failure(
        code: response.code.toString(),
        message: _failureMessage(response),
      );
    }
    return StoreApiResponse.success(null, message: 'ok');
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

  static StoreApiResponse<T> _parseObject<T>(
    NineBaseResponse response,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (!_isBusinessSuccess(response)) {
      return StoreApiResponse.failure(
        code: response.code.toString(),
        message: _failureMessage(response),
      );
    }

    final raw = response.data;
    if (raw is! Map) {
      NLog.e('StoreApi 对象格式异常 raw=$raw type=${raw.runtimeType}');
      return StoreApiResponse.failure(code: '1001', message: '响应数据格式错误');
    }

    try {
      return StoreApiResponse.success(
        parser(Map<String, dynamic>.from(raw)),
        message: response.message.isNotEmpty ? response.message : 'ok',
      );
    } catch (e, stack) {
      NLog.e('StoreApi 解析对象失败: $e\n$stack');
      return StoreApiResponse.failure(code: '1001', message: '数据解析失败');
    }
  }

  static StoreApiResponse<List<T>> _parseList<T>(
    NineBaseResponse response,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (!_isBusinessSuccess(response)) {
      return StoreApiResponse.failure(
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
    } else if (raw is Map && raw['data'] is List) {
      items = raw['data'] as List<dynamic>;
    } else {
      NLog.e('StoreApi 列表格式异常 raw=$raw type=${raw.runtimeType}');
      return StoreApiResponse.failure(code: '1001', message: '响应数据格式错误');
    }

    final list = <T>[];
    for (final item in items) {
      if (item is! Map) {
        continue;
      }
      try {
        list.add(parser(Map<String, dynamic>.from(item)));
      } catch (e, stack) {
        NLog.e('StoreApi 解析列表项失败: $e item=$item\n$stack');
      }
    }

    return StoreApiResponse.success(
      list,
      message: response.message.isNotEmpty ? response.message : 'ok',
    );
  }
}
