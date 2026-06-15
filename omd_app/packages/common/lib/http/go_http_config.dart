import 'package:network/base/base_response.dart';
import 'package:network/base/nine_http_config.dart';
import 'package:network/config/uuid_service.dart';

class GoHttpConfig implements NineHttpConfig {
  GoHttpConfig._();
  static final GoHttpConfig instance = GoHttpConfig._();
  String _token = '';
  void Function()? onSessionExpired;

  void updateToken(String token) {
    _token = token.trim();
  }

  @override
  String get token => _token;

  @override
  void onTokenError(NineBaseResponse response) {
    onSessionExpired?.call();
  }

  @override
  void showMsgTost(NineBaseResponse response) {}

  @override
  String get deviceId => UuidService.currentDeviceID;

  @override
  bool get isLogin => _token.isNotEmpty;

  bool get isTenantLogin => token.isNotEmpty;
}
