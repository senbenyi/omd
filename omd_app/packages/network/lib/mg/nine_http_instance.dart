import 'dart:async';
import 'dart:io';

import 'package:base/log/nine_log.dart';
import 'package:dio/dio.dart';
import 'package:network/base/base_domain_config.dart';
import 'package:network/base/base_response.dart';
import 'package:network/interceptor/nine_alice.dart';
import 'package:network/interceptor/nine_decrypt_response_interceptor.dart';
import 'package:network/interceptor/nine_encrypt_request_interceptor.dart';
import 'package:network/http/nine_error_handle.dart';
import 'package:network/http/permissive_tls.dart';
import 'package:network/base/nine_http_config.dart';
import 'package:network/http/nine_response_handle.dart';

class NineHttpInstance {
  NineHttpConfig? httpConfig;
  BaseDomainConfig? domainConfig;

  NineHttpInstance({this.httpConfig, this.domainConfig}) {
    _installAliceRequestInterceptor();
    _installEncryptInterceptor();
    _installDecryptInterceptor();
    _installAliceResponseInterceptor();
  }

  final dio = Dio();
  bool _encryptInterceptorInstalled = false;
  bool _aliceRequestInterceptorInstalled = false;
  bool _aliceResponseInterceptorInstalled = false;
  bool _decryptInterceptorInstalled = false;

  void _installEncryptInterceptor() {
    if (_encryptInterceptorInstalled) return;
    dio.interceptors.add(NineEncryptRequestInterceptor());
    _encryptInterceptorInstalled = true;
  }

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

  void _installDecryptInterceptor() {
    if (_decryptInterceptorInstalled) return;
    dio.interceptors.add(NineDecryptResponseInterceptor());
    _decryptInterceptorInstalled = true;
  }

  Map<String, String> _generateHeaders({
    required bool isEncrypt,
    required bool isFormData,
    Map<String, String>? headers,
  }) {
    final token = httpConfig?.token ?? "";
    final deviceId = httpConfig?.deviceId ?? "";

    final newHeader = <String, String>{
      'Authorization': 'Bearer $token',
      'X-Should-Encrypt': isEncrypt ? '1' : "0",
      'X-AUTH-UUID': deviceId,
    };
    if (!isFormData) {
      newHeader[HttpHeaders.contentTypeHeader] = 'application/json';
    }

    if (headers != null) {
      newHeader.addAll(headers);
    }

    return newHeader;
  }

  Dio _dioWithTrustAllCertificates() {
    final d = Dio();
    configurePermissiveTlsTrustAll(d);
    for (final interceptor in dio.interceptors) {
      d.interceptors.add(interceptor);
    }
    return d;
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
    bool trustAllCertificates = false,
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
      trustAllCertificates: trustAllCertificates,
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
          trustAllCertificates: trustAllCertificates,
        );
      }
    }
    return response;
  }

  Future<NineBaseResponse> uploadFile({
    required String url,
    required FormData formData,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool showLoading = false,
    bool needToast = true,
  }) async {
    NineBaseResponse response = await fetchData(
      path: url,
      headers: headers,
      formData: formData,
      method: DioMethods.POST,
    );
    if (response.error is DioException) {
      bool needRetry = NineErrorHandle.shouldRetry(response.error);
      if (needRetry) {
        response = await fetchData(
          path: url,
          headers: headers,
          formData: formData,
          method: DioMethods.POST,
          timeoutSeconds: 120,
          isRetry: true,
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
    bool isRetry = false,
    int timeoutSeconds = 15,
    bool trustAllCertificates = false,
  }) async {
    Completer<NineBaseResponse> completer = Completer();
    String baseUrl = domain ?? "";
    if (baseUrl.isEmpty) {
      baseUrl = (domainConfig?.currentBaseUrl ?? "");
    }
    final Dio fetchClient =
        trustAllCertificates ? _dioWithTrustAllCertificates() : dio;
    try {
      bool isFormData = true;
      if (formData != null) {
        isFormData = true;
      } else if (params == null) {
        isFormData = false;
      } else if (params.isEmpty || requesNeedEncryped) {
        isFormData = false;
      }
      dynamic paramData;
      if (isFormData) {
        paramData = formData ?? FormData.fromMap(params!);
      } else {
        paramData = params;
      }
      final generatedHeaders = _generateHeaders(
        isEncrypt: requesNeedEncryped,
        headers: headers,
        isFormData: isFormData,
      );

      RequestOptions options = RequestOptions(
        method: method.name,
        baseUrl: baseUrl,
        path: path,
        queryParameters: queryParameters,
        data: paramData,
        followRedirects: false,
        receiveTimeout: Duration(seconds: timeoutSeconds),
        sendTimeout: Duration(seconds: timeoutSeconds),
        connectTimeout: Duration(seconds: timeoutSeconds),
        headers: generatedHeaders,
        extra: {'responseIsEncrypted': responseIsEncryped},
      );
      NLog.d(
        "${isRetry ? "重试" : ""}开始请求：${method.name} url:$baseUrl$path param:$params headers：$generatedHeaders",
      );
      Response response = await fetchClient.fetch(options);
      NineBaseResponse res = NineResponseHandle.handleResponse(
        response,
        config: httpConfig,
      );
      if (!completer.isCompleted) {
        completer.complete(res);
      }
    } on DioException catch (error) {
      NLog.e(
        "${isRetry ? "重试" : ""} url:$baseUrl$path param:$params error:$error",
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
      NLog.e("${isRetry ? "重试" : ""} url:$baseUrl$path param:$params error:$e");
      NineBaseResponse res = NineBaseResponse(error: e);
      if (!completer.isCompleted) {
        completer.complete(res);
      }
    }
    NineBaseResponse response = await completer.future;
    return response;
  }

  static Future<void> downloadFile({
    required String url,
    required String savePath,
    void Function(int received, int total)? onProgress,
  }) async {
    final dio = Dio(
      BaseOptions(
        receiveTimeout: Duration(milliseconds: 60000),
        connectTimeout: Duration(milliseconds: 60000),
      ),
    );
    await dio.download(
      url,
      savePath,
      onReceiveProgress: onProgress,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
      ),
    );
  }
}
