import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:network/encry/http_crypto.dart';

class NineDecryptResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final needDecrypt =
        response.requestOptions.extra['responseIsEncrypted'] == true;
    final data = response.data;
    if (!needDecrypt ||
        response.statusCode != 200 ||
        data is! String ||
        data.isEmpty) {
      handler.next(response);
      return;
    }

    final decrypted = HttpCrypto.decrypt(data);
    if (decrypted == 'Error decrypt') {
      handler.next(response);
      return;
    }

    try {
      response.data = jsonDecode(decrypted);
    } catch (_) {
      response.data = decrypted;
    }
    handler.next(response);
  }
}
