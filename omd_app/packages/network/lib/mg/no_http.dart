import 'package:base/toast/nine_progress_hud.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:dio/dio.dart';
import 'package:network/base/base_response.dart';
import 'package:network/base/http_base_module.dart';
import 'package:network/base/nine_http_config.dart';
import 'package:network/mg/nine_http_instance.dart';
import 'package:network/mg/no_domian_config.dart';

class NOHttp implements HttpBaseModule {
  static final _instanceSingle = NOHttp._internal();
  factory NOHttp() => _instanceSingle;
  static NOHttp get instance => NOHttp();
  NOHttp._internal() : super();

  late NineHttpInstance httpUnitl;

  @override
  Future<void> registerHttpServer(NineHttpConfig httpConfig) async {
    NODomianConfig domianConfig = NODomianConfig.instance;
    await domianConfig.initBaseUrl();
    httpUnitl = NineHttpInstance(
      httpConfig: httpConfig,
      domainConfig: domianConfig,
    );
  }

  @override
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
  }) async {
    if (showLoading) {
      NineProgressHud.showLoading();
    }
    NineBaseResponse res = await httpUnitl.request(
      url: url,
      domain: domain,
      headers: headers,
      method: method,
      params: params,
      queryParameters: queryParameters,
      requesNeedEncryped: needRequetEncry,
      responseIsEncryped: responseIsEncryped,
      cancelToken: cancelToken,
      trustAllCertificates: trustAllCertificates,
    );
    if (showLoading) {
      NineProgressHud.dismiss();
    }
    String message = res.message.isNotEmpty ? res.message : res.statusMessage;
    if (res.code != 200 && message.isNotEmpty && needToast) {
      showAppToast(message);
    }
    return res;
  }

  @override
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
  }) async {
    if (showLoading) {
      NineProgressHud.showLoading();
    }
    NineBaseResponse res = await httpUnitl.request(
      url: url,
      domain: domain,
      headers: headers,
      method: method,
      params: params,
      queryParameters: queryParameters,
      requesNeedEncryped: needRequetEncry,
      responseIsEncryped: responseIsEncryped,
      cancelToken: cancelToken,
      trustAllCertificates: trustAllCertificates,
    );
    if (showLoading) {
      NineProgressHud.dismiss();
    }
    String message = res.message.isNotEmpty ? res.message : res.statusMessage;
    if (res.code != 200 && message.isNotEmpty && needToast) {
      showAppToast(message);
    }
    return res;
  }

  Future<NineBaseResponse> uploadFile({
    required String url,
    required FormData formData,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool showLoading = false,
    bool needToast = true,
  }) async {
    if (showLoading) {
      NineProgressHud.showLoading();
    }
    NineBaseResponse res = await httpUnitl.uploadFile(
      url: url,
      headers: headers,
      formData: formData,
      cancelToken: cancelToken,
    );
    if (showLoading) {
      NineProgressHud.dismiss();
    }
    String message = res.message.isNotEmpty ? res.message : res.statusMessage;
    if (res.code != 200 && message.isNotEmpty && needToast) {
      showAppToast(message);
    }
    return res;
  }
}
