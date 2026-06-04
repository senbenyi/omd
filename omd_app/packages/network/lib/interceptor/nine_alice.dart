import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_alice/alice.dart';

class NineAlice {
  NineAlice._();

  static Alice? _alice;
  static Interceptor? _dioInterceptor;

  static void init({required GlobalKey<NavigatorState> navigatorKey}) {
    if (!kDebugMode) return;
    _alice ??= Alice(
      navigatorKey: navigatorKey,
      showNotification: false,
    );
    _dioInterceptor ??= _alice?.getDioInterceptor();
  }

  static Interceptor? get requestInterceptor {
    final interceptor = _dioInterceptor;
    if (interceptor == null) return null;
    return _AliceRequestInterceptor(interceptor);
  }

  static Interceptor? get responseInterceptor {
    final interceptor = _dioInterceptor;
    if (interceptor == null) return null;
    return _AliceResponseInterceptor(interceptor);
  }

  static void showInspector() {
    _alice?.showInspector();
  }
}

class _AliceRequestInterceptor extends Interceptor {
  _AliceRequestInterceptor(this._delegate);

  final Interceptor _delegate;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _delegate.onRequest(options, handler);
  }
}

class _AliceResponseInterceptor extends Interceptor {
  _AliceResponseInterceptor(this._delegate);

  final Interceptor _delegate;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _delegate.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _delegate.onError(err, handler);
  }
}
