import 'dart:async';

import 'package:network/base/base_domain_config.dart';
import 'package:base/log/nine_log.dart';
import 'package:dio/dio.dart';
import 'package:network/base/nine_http_config.dart';
import 'package:network/interceptor/nine_alice.dart';

import 'package:network/base/base_response.dart';
import 'package:network/http/nine_error_handle.dart';
import 'package:network/http/nine_response_handle.dart';

class GoHttpInstance {
  NineHttpConfig? httpConfig;
  BaseDomainConfig? domainConfig;
  GoHttpInstance({this.httpConfig, this.domainConfig}) {
    _installAliceRequestInterceptor();

    _installAliceResponseInterceptor();
  }

  final dio = Dio();

  bool _aliceRequestInterceptorInstalled = false;
  bool _aliceResponseInterceptorInstalled = false;

  void _installAliceRequestInterceptor() {
    if (_aliceRequestInterceptorInstalled) return;
    final aliceRequestInterceptor = NineAlice.requestInterceptor;
    if (aliceRequestInterceptor == null) return;
    dio.interceptors.add(aliceRequestInterceptor);
    _aliceRequestInterceptorInstalled = true;
  }

  void _installAliceResponseInterceptor() {
    if (_aliceResponseInterceptorInstalled) return;
    final aliceResponseInterceptor = NineAlice.responseInterceptor;
    if (aliceResponseInterceptor == null) return;
    dio.interceptors.add(aliceResponseInterceptor);
    _aliceResponseInterceptorInstalled = true;
  }

  Map<String, String> _generateHeaders({
    required bool isEncrypt,
    required bool responseDecrypt,
    required bool isFormData,
    Map<String, String>? headers,
  }) {
    final token = httpConfig?.token ?? "";
    final deviceId = httpConfig?.deviceId ?? "";

    final newHeader = <String, String>{"Accept-language": "zh-CN"};
    if (!isFormData) {
      newHeader["Content-type"] = "application/json";
    }
    if (token.isNotEmpty) {
      newHeader["Authorization"] = 'Bearer $token';
    }
    if (deviceId.isNotEmpty) {
      newHeader["Device-Id"] = deviceId;
    }

    if (headers != null) {
      newHeader.addAll(headers);
    }

    return newHeader;
  }

  Future<NineBaseResponse> request({
    required String url,
    required bool requesNeedEncryped,
    required bool responseIsEncryped,
    String? domain,
    Map<String, dynamic>? params,
    dynamic queryParameters,
    DioMethods method = DioMethods.POST,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    NineBaseResponse response = await fetchData(
      path: url,
      domain: domain,
      method: method,
      headers: headers,
      params: params,
      queryParameters: queryParameters,
      requesNeedEncryped: requesNeedEncryped,
      responseIsEncryped: responseIsEncryped,
    );
    if (response.error is DioException) {
      bool needRetry = NineErrorHandle.shouldRetry(response.error);
      if (needRetry) {
        response = await fetchData(
          path: url,
          domain: domain,
          method: method,
          headers: headers,
          params: params,
          queryParameters: queryParameters,
          isRetry: true,
          requesNeedEncryped: requesNeedEncryped,
          responseIsEncryped: responseIsEncryped,
        );
      }
    }
    return response;
  }

  Future<NineBaseResponse> uploadFile({
    required String url,
    required FormData formData,

    CancelToken? cancelToken,
  }) async {
    NineBaseResponse response = await fetchData(
      path: url,
      headers: {'Content-Type': 'multipart/form-data'},
      formData: formData,

      method: DioMethods.POST,
      cancelToken: cancelToken,
    );
    if (response.error is DioException) {
      final needRetry = NineErrorHandle.shouldRetry(response.error);
      if (needRetry) {
        response = await fetchData(
          path: url,
          headers: {'Content-Type': 'multipart/form-data'},
          formData: formData,
          method: DioMethods.POST,
          timeoutSeconds: 120,
          isRetry: true,
          cancelToken: cancelToken,
        );
      }
    }
    return response;
  }

  Future<NineBaseResponse> fetchData({
    required String path,
    DioMethods method = DioMethods.POST,
    String? domain,
    Map<String, dynamic>? params,
    FormData? formData,
    dynamic queryParameters,
    bool requesNeedEncryped = false,
    bool responseIsEncryped = true,

    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool isRetry = false,
    int timeoutSeconds = 15,
  }) async {
    Completer<NineBaseResponse> completer = Completer();
    String baseUrl = domain ?? (domainConfig?.currentBaseUrl ?? "");
    baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), '');
    try {
      bool isFormData = false;
      if (formData != null) {
        isFormData = true;
      }
      dynamic paramData;
      if (isFormData) {
        paramData = formData;
      } else {
        paramData = params;
      }
      final generatedHeaders = _generateHeaders(
        isEncrypt: requesNeedEncryped,
        responseDecrypt: responseIsEncryped,
        isFormData: isFormData,
        headers: headers,
      );
      RequestOptions options = RequestOptions(
        method: method.name,
        baseUrl: baseUrl,
        path: path,
        queryParameters: queryParameters,
        data: paramData,
        cancelToken: cancelToken,
        responseType: ResponseType.json,
        receiveTimeout: Duration(seconds: timeoutSeconds),
        sendTimeout: Duration(seconds: timeoutSeconds),
        connectTimeout: Duration(seconds: timeoutSeconds),
        headers: generatedHeaders,
        followRedirects: true,
        // 业务错误常以 4xx 返回 JSON（如 412 + code:1101），需走正常响应解析而非 DioException
        validateStatus: (s) => s != null && s >= 200 && s < 500,
      );
      NLog.d(
        "${isRetry ? "重试" : ""}GOHTTP开始请求：${method.name} url:$baseUrl$path "
        "body:$params query:$queryParameters headers：$generatedHeaders",
      );
      Response response = await dio.fetch(options);

      NineBaseResponse res = _handleGoResponse(response);
      if (!completer.isCompleted) {
        completer.complete(res);
      }
    } on DioException catch (error) {
      final errBody = error.response?.data;
      NLog.e(
        "${isRetry ? "重试" : ""} url:$baseUrl$path body:$params query:$queryParameters "
        "status:${error.response?.statusCode} responseBody:$errBody error:$error",
      );
      if (isRetry) {
        bool needChange = NineErrorHandle.shouldChangeDomian(error);
        if (needChange) {
          domainConfig?.checkNewDomian();
        }
      }
      NineBaseResponse res = NineErrorHandle.handleDioException(error);
      if (!completer.isCompleted) {
        completer.complete(res);
      }
    } catch (e) {
      NLog.e(
        "${isRetry ? "重试" : ""} url:$baseUrl$path body:$params query:$queryParameters error:$e",
      );
      NineBaseResponse res = NineBaseResponse(error: e);
      if (!completer.isCompleted) {
        completer.complete(res);
      }
    }
    NineBaseResponse response = await completer.future;
    return response;
  }

  NineBaseResponse _handleGoResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic> &&
        (data.containsKey('code') ||
            data.containsKey('data') ||
            data.containsKey('items'))) {
      return NineResponseHandle.handleResponse(response, config: httpConfig);
    }

    final statusCode = response.statusCode ?? 0;
    final message = _extractHttpErrorMessage(data, response.statusMessage);

    NLog.d(
      "GOHTTP返回直接数据: url:${response.requestOptions.uri} "
      "statusCode:$statusCode data:$data message:$message",
    );
    return NineBaseResponse(
      data: null,
      statusCode: statusCode,
      statusMessage: response.statusMessage ?? '',
      message: message,
      code: statusCode > 0 ? statusCode : -1,
    );
  }

  String _extractHttpErrorMessage(dynamic data, String? statusMessage) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final direct = map['message'] ?? map['title'];
      if (direct != null && direct.toString().isNotEmpty) {
        return direct.toString();
      }
      final errors = map['errors'];
      if (errors is Map) {
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
          if (value != null && value.toString().isNotEmpty) {
            return value.toString();
          }
        }
      }
    }
    if (statusMessage != null && statusMessage.isNotEmpty) {
      return statusMessage;
    }
    return '请求失败';
  }
}
