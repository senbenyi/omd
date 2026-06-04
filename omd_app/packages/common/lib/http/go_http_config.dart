import 'package:network/base/base_response.dart';
import 'package:network/base/nine_http_config.dart';
import 'package:network/config/uuid_service.dart';

class GoHttpConfig implements NineHttpConfig {
  GoHttpConfig._();
  static final GoHttpConfig instance = GoHttpConfig._();
  String _token = '';

  void updateToken(String token) {
    _token = token;
  }

  @override
  String get token => _token;

  @override
  void onTokenError(NineBaseResponse response) {}

  @override
  void showMsgTost(NineBaseResponse response) {}

  @override
  String get deviceId => UuidService.currentDeviceID;

  @override
  bool get isLogin => false;

  bool get isTenantLogin => token.isNotEmpty;
}
