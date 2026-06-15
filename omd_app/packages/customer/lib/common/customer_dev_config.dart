import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// 本地开发 API 地址。
abstract final class CustomerDevConfig {
  static const int apiPort = 5080;
  static const String apiPath = '/restaurant/v1';

  static const String _hostOverride = String.fromEnvironment('STORE_DEV_HOST');

  static String get devHost {
    if (_hostOverride.isNotEmpty) return _hostOverride;
    if (kIsWeb) return '127.0.0.1';
    if (Platform.isAndroid) return '10.0.2.2';
    return '127.0.0.1';
  }

  static String get devDomain => 'http://$devHost:$apiPort$apiPath';
}
