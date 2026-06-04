import 'dart:convert';
import 'dart:math';

import 'package:base/log/nine_log.dart';
import 'package:dio/dio.dart';
import 'package:network/encry/http_crypto.dart';

class NineEncryptRequestInterceptor extends Interceptor {
  static const String encryptHeaderKey = 'X-Should-Encrypt';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final shouldEncrypt = options.headers[encryptHeaderKey]?.toString() == '1';
    if (!shouldEncrypt) {
      handler.next(options);
      return;
    }

    final data = options.data;
    if (data == null || data is FormData) {
      handler.next(options);
      return;
    }

    final plainText = data is String ? data : jsonEncode(data);
    options.data = HttpCrypto.encrypt(plainText);
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
    NLog.d("================http异常=============");
    NLog.d("${err.requestOptions.baseUrl}${err.requestOptions.path}");
    NLog.e(err.toString());
    NLog.d("=============================");
  }
}
