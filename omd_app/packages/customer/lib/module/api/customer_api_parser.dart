import 'package:base/log/nine_log.dart';
import 'package:customer/module/api/customer_api_response.dart';
import 'package:network/base/base_response.dart';

class CustomerApiParser {
  CustomerApiParser._();

  static CustomerApiResponse<T> parseObject<T>(
    NineBaseResponse response,
    T Function(Map<String, dynamic>) parser, {
    String logTag = 'CustomerApi',
  }) {
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
      NLog.e('$logTag 解析对象失败: $e\n$stack');
      return CustomerApiResponse(code: '1001', message: '数据解析失败');
    }
  }

  static CustomerApiResponse<T?> parseNullableObject<T>(
    NineBaseResponse response,
    T Function(Map<String, dynamic>) parser, {
    String logTag = 'CustomerApi',
  }) {
    if (!_isBusinessSuccess(response)) {
      return CustomerApiResponse(
        code: response.code.toString(),
        message: _failureMessage(response),
      );
    }
    final raw = response.data;
    if (raw == null) {
      return CustomerApiResponse(code: '0', message: 'ok', data: null);
    }
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
      NLog.e('$logTag 解析对象失败: $e\n$stack');
      return CustomerApiResponse(code: '1001', message: '数据解析失败');
    }
  }

  static CustomerApiResponse<List<T>> parseList<T>(
    NineBaseResponse response,
    T Function(Map<String, dynamic>) parser, {
    String logTag = 'CustomerApi',
  }) {
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
        NLog.e('$logTag 解析列表项失败: $e item=$item\n$stack');
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
