import 'package:network/base/base_response.dart';

// ignore: constant_identifier_names
enum DioMethods { POST, GET, PUT, DELETE }

abstract class NineHttpConfig {
  String get token;
  String get deviceId;
  bool get isLogin;
  void onTokenError(NineBaseResponse response);
  void showMsgTost(NineBaseResponse response);
}
