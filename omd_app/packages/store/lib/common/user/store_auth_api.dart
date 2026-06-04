import 'package:common/http/go_http.dart';
import 'package:network/base/base_response.dart';
import 'package:store/module/login/store_auth_models.dart';

/// 认证相关接口，与 [omd_api.openapi.yaml] 对齐。
class StoreAuthApi {
  StoreAuthApi._();

  /// POST /auth/login — 密码登录（无需鉴权）
  static const String loginApi = '/auth/login';

  /// POST /auth/register — 注册（无需鉴权）
  static const String registerApi = '/auth/register';

  static Future<StoreApiResponse<StoreAuthData>> login(
    StoreAuthLoginRequest request,
  ) async {
    return _postAuth(loginApi, request.toJson());
  }

  static Future<StoreApiResponse<StoreAuthData>> register(
    StoreAuthRegisterRequest request,
  ) async {
    return _postAuth(registerApi, request.toJson());
  }

  static Future<StoreApiResponse<StoreAuthData>> _postAuth(
    String url,
    Map<String, dynamic> params,
  ) async {
    final response = await GoHttp.instance.post(
      url: url,
      params: params,
      needRequetEncry: false,
      responseIsEncryped: false,
      needToast: false,
    );
    return _parseAuthResponse(response);
  }

  static StoreApiResponse<StoreAuthData> _parseAuthResponse(
    NineBaseResponse response,
  ) {
    if (response.error != null || response.statusCode >= 400) {
      return StoreApiResponse.failure(
        code: response.code.toString(),
        message:
            response.message.isNotEmpty
                ? response.message
                : (response.statusMessage.isNotEmpty
                    ? response.statusMessage
                    : '请求失败'),
      );
    }

    final businessCode = response.code.toString();
    if (businessCode != '0') {
      return StoreApiResponse.failure(
        code: businessCode,
        message:
            response.message.isNotEmpty ? response.message : '请求失败',
      );
    }

    final raw = response.data;
    if (raw is! Map) {
      return StoreApiResponse.failure(code: '1001', message: '响应数据格式错误');
    }

    return StoreApiResponse.success(
      StoreAuthData.fromJson(Map<String, dynamic>.from(raw)),
      message: response.message.isNotEmpty ? response.message : 'ok',
    );
  }
}
