import 'dart:convert';

import 'package:base/log/nine_log.dart';
import 'package:base/toast/nine_progress_hud.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:base/utils/app_channel.dart';
import 'package:base/utils/nine_env.dart';
import 'package:common/http/go_http_config.dart';
import 'package:common/utils/SharedStorageUtil.dart';
import 'package:get/get.dart';
import 'package:store/common/user/go_user_login_model.dart';
import 'package:store/common/user/store_auth_api.dart';
import 'package:store/module/login/store_auth_models.dart';

class GoUserController extends GetxController {
  static GoUserController get to => Get.find<GoUserController>();

  final loginInfo = Rx<GoUserLoginModel?>(null);
  final token = ''.obs;
  final isLogin = false.obs;
  final sessionChecked = false.obs;

  late final String _loginInfoKey;

  bool get hasValidToken => _normalizeToken(token.value).isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loginInfoKey = _buildLoginInfoKey();
  }

  /// 启动时恢复本地登录态，需在 [runApp] 之前 await。
  Future<void> restoreLocalSession() async {
    sessionChecked.value = false;
    _resetSessionState();
    await getLocalLoginInfo();
  }

  Future<void> saveLoginInfo(GoUserLoginModel model) async {
    if (!_canRestoreSession(model)) {
      await clearLoginInfo(showToast: false);
      return;
    }

    _applySession(model);
    await SharedStorageUtil.setString(
      _loginInfoKey,
      jsonEncode(model.toJson()),
    );
    NLog.d('Go 登录信息保存成功 userId=${model.displayUserId}');
  }

  Future<Object?> saveLoginResponse(dynamic data) async {
    if (data is StoreAuthData) {
      await saveLoginInfo(GoUserLoginModel.fromAuthData(data));
      return true;
    }
    if (data is! Map) {
      return false;
    }

    final map = Map<String, dynamic>.from(data);
    final model = GoUserLoginModel.fromJson(map);
    if (!_canRestoreSession(model)) {
      NLog.d('Go 登录成功但缺少有效 token 或用户标识');
      return false;
    }
    await saveLoginInfo(model);
    return true;
  }

  Future<bool> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    return _performAuth(() {
      return StoreAuthApi.login(
        StoreAuthLoginRequest(phone: phone.trim(), password: password),
      );
    }, successMessage: '登录成功');
  }

  Future<bool> register({
    required String phone,
    required String password,
    String? username,
  }) async {
    return _performAuth(() {
      return StoreAuthApi.register(
        StoreAuthRegisterRequest(
          phone: phone.trim(),
          password: password,
          username: username?.trim(),
        ),
      );
    }, successMessage: '注册成功');
  }

  Future<void> getLocalLoginInfo() async {
    try {
      final jsonText = SharedStorageUtil.getString(_loginInfoKey);
      if (jsonText.isEmpty) {
        return;
      }

      final json = jsonDecode(jsonText);
      if (json is! Map) {
        await clearLoginInfo(showToast: false);
        return;
      }

      final model = GoUserLoginModel.fromJson(Map<String, dynamic>.from(json));
      if (!_canRestoreSession(model)) {
        NLog.d('Go 本地登录信息无效，已清理缓存 userId=${model.displayUserId}');
        await clearLoginInfo(showToast: false);
        return;
      }

      _applySession(model);
      NLog.d('Go 本地登录信息恢复成功 userId=${model.displayUserId}');
    } catch (e) {
      NLog.d('Go 本地登录信息读取失败 $e');
      await clearLoginInfo(showToast: false);
    } finally {
      sessionChecked.value = true;
    }
  }

  Future<void> logOut() {
    return clearLoginInfo(showToast: true);
  }

  Future<void> clearLoginInfo({bool showToast = false}) async {
    _resetSessionState();
    await SharedStorageUtil.remove(_loginInfoKey);
    if (showToast) {
      showAppToast('已退出登录');
    }
  }

  Future<bool> _performAuth(
    Future<StoreApiResponse<StoreAuthData>> Function() request, {
    required String successMessage,
  }) async {
    NineProgressHud.showLoading();
    try {
      final response = await request();
      if (!response.isSuccess || response.data == null) {
        showAppToast(response.message.isNotEmpty ? response.message : '请求失败');
        return false;
      }
      await saveLoginInfo(GoUserLoginModel.fromAuthData(response.data!));
      showAppToast(
        response.message.isNotEmpty && response.message != 'ok'
            ? response.message
            : successMessage,
      );
      return true;
    } finally {
      NineProgressHud.dismiss();
    }
  }

  void _applySession(GoUserLoginModel model) {
    final normalizedToken = _normalizeToken(model.token);
    loginInfo.value = model;
    token.value = normalizedToken;
    isLogin.value = normalizedToken.isNotEmpty;
    GoHttpConfig.instance.updateToken(normalizedToken);
  }

  void _resetSessionState() {
    loginInfo.value = null;
    token.value = '';
    isLogin.value = false;
    GoHttpConfig.instance.updateToken('');
  }

  bool _canRestoreSession(GoUserLoginModel model) {
    return _normalizeToken(model.token).isNotEmpty && model.hasLoginIdentity;
  }

  static String _normalizeToken(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty || normalized == 'null') {
      return '';
    }
    return normalized;
  }

  String _buildLoginInfoKey() {
    String channel = 'go';
    try {
      channel = AppChannel.getChannel().channleType.name;
    } catch (_) {}
    return '${channel}_${offerEnv.name}_go_login_info';
  }
}
