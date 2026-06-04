import 'package:dio/dio.dart';
import 'package:network/base/base_response.dart';
import 'package:network/base/nine_http_config.dart';

abstract class HttpBaseModule {
  Future<void> registerHttpServer(NineHttpConfig httpConfig);

  Future<NineBaseResponse> post({
    required String url,
    bool needRequetEncry = false,
    bool responseIsEncryped = true,
    String? domain,
    Map<String, dynamic>? params,
    dynamic queryParameters,
    DioMethods method = DioMethods.POST,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool showLoading = false,
    bool needToast = true,
    bool trustAllCertificates = false,
  });

  Future<NineBaseResponse> get({
    required String url,
    bool needRequetEncry = false,
    bool responseIsEncryped = true,
    String? domain,
    Map<String, dynamic>? params,
    dynamic queryParameters,
    DioMethods method = DioMethods.GET,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool showLoading = false,
    bool needToast = true,
    bool trustAllCertificates = false,
  });
}
