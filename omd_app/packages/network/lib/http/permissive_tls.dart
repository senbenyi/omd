import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Trusts any TLS server certificate ([badCertificateCallback] always true).
///
/// **Security:** enables MITM on traffic using this [Dio]. Use only for narrowly
/// scoped calls (e.g. a single third-party API where the chain is not trusted
/// on-device).
void configurePermissiveTlsTrustAll(Dio dio) {
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    },
  );
}
