import 'package:common/http/go_domian_config.dart';
import 'package:common/http/go_http_instance.dart';
import 'package:dio/dio.dart';
import 'package:network/base/base_response.dart';
import 'package:base/toast/nine_progress_hud.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:network/base/nine_http_config.dart';

class GoHttp {
  static final _instanceSingle = GoHttp._internal();
  factory GoHttp() => _instanceSingle;
  static GoHttp get instance => GoHttp();
  GoHttp._internal() : super();
  late GoHttpInstance httpUnitl;

  Future<void> registerHttpServer(NineHttpConfig httpConfig) async {
    final GoDomianConfig domianConfig = GoDomianConfig.instance;
    await domianConfig.initBaseUrl();

    httpUnitl = GoHttpInstance(
      httpConfig: httpConfig,
      domainConfig: domianConfig,
    );
  }

  Future<NineBaseResponse> post({
    required String url,
    bool needRequetEncry = false,
    bool responseIsEncryped = false,
    String? domain,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool showLoading = false,
    bool needToast = true,
  }) async {
    if (showLoading) {
      NineProgressHud.showLoading();
    }
    NineBaseResponse res = await httpUnitl.request(
      url: url,
      domain: domain,
      headers: headers,
      method: DioMethods.POST,
      params: params,
      requesNeedEncryped: needRequetEncry,
      responseIsEncryped: responseIsEncryped,
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

  Future<NineBaseResponse> get({
    required String url,
    bool needRequetEncry = true,
    bool responseIsEncryped = true,
    String? domain,
    dynamic queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool showLoading = false,
    bool needToast = true,
  }) async {
    if (showLoading) {
      NineProgressHud.showLoading();
    }
    NineBaseResponse res = await httpUnitl.request(
      url: url,
      domain: domain,
      headers: headers,
      method: DioMethods.GET,
      queryParameters: queryParameters,
      requesNeedEncryped: needRequetEncry,
      responseIsEncryped: responseIsEncryped,
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

  Future<NineBaseResponse> put({
    required String url,
    bool needRequetEncry = false,
    bool responseIsEncryped = false,
    String? domain,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool showLoading = false,
    bool needToast = true,
  }) async {
    if (showLoading) {
      NineProgressHud.showLoading();
    }
    final res = await httpUnitl.request(
      url: url,
      domain: domain,
      headers: headers,
      method: DioMethods.PUT,
      params: params,
      requesNeedEncryped: needRequetEncry,
      responseIsEncryped: responseIsEncryped,
      cancelToken: cancelToken,
    );
    if (showLoading) {
      NineProgressHud.dismiss();
    }
    final message = res.message.isNotEmpty ? res.message : res.statusMessage;
    if (res.code != 200 && message.isNotEmpty && needToast) {
      showAppToast(message);
    }
    return res;
  }

  Future<NineBaseResponse> delete({
    required String url,
    bool needRequetEncry = false,
    bool responseIsEncryped = false,
    String? domain,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    bool showLoading = false,
    bool needToast = true,
  }) async {
    if (showLoading) {
      NineProgressHud.showLoading();
    }
    final res = await httpUnitl.request(
      url: url,
      domain: domain,
      headers: headers,
      method: DioMethods.DELETE,
      params: params,
      requesNeedEncryped: needRequetEncry,
      responseIsEncryped: responseIsEncryped,
      cancelToken: cancelToken,
    );
    if (showLoading) {
      NineProgressHud.dismiss();
    }
    final message = res.message.isNotEmpty ? res.message : res.statusMessage;
    if (res.code != 200 && message.isNotEmpty && needToast) {
      showAppToast(message);
    }
    return res;
  }

  Future<NineBaseResponse> uploadFile({
    required String url,
    required FormData formData,

    CancelToken? cancelToken,
    bool showLoading = false,
    bool needToast = true,
  }) async {
    if (showLoading) {
      NineProgressHud.showLoading();
    }
    NineBaseResponse res = await httpUnitl.uploadFile(
      url: url,
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
