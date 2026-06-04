import 'dart:convert';

import 'package:base/log/nine_log.dart';
import 'package:dio/dio.dart';
import 'package:network/base/base_response.dart';
import 'package:network/base/nine_http_config.dart';

class NineResponseHandle {
  static NineBaseResponse handleResponse(
    Response response, {
    NineHttpConfig? config,
  }) {
    try {
      dynamic data = response.data;

      Map<String, dynamic> resData = {};
      if (data is String) {
        resData = jsonDecode(data);
      } else if (data is Map<String, dynamic>) {
        resData = data;
      }
      int code = 0;
      dynamic serverCode = resData["code"];
      if (serverCode is String) {
        code = int.parse(serverCode);
      } else if (serverCode is int) {
        code = serverCode;
      }

      String message = resData["message"] ?? "";
      NLog.d(
        "TYHTTP返回数据: url:${response.requestOptions.uri} code:$code data:$resData message:$message statusCode:${response.statusCode} statusMessage:${response.statusMessage}",
      );
      NineBaseResponse res = NineBaseResponse(
        data: resData['items'] ?? resData['data'],
        statusCode: response.statusCode ?? 0,
        statusMessage: response.statusMessage ?? "",
        message: message,
        code: code,
        currentPage: intFormat(resData['currentPage'], def: 1),
        pageSize: intFormat(resData['pageSize']),
        totalNum: intFormat(resData['totalNum']),
        totalPage: intFormat(resData['totalPage']),
      );
      if (code != 200) {
        handdleErrorResponse(res, config: config);
      }
      return res;
    } catch (e) {
      NLog.e("数据解析异常${response.realUri} error：$e response:$response");
      return NineBaseResponse(message: "数据解析异常");
    }
  }

  static void handdleErrorResponse(
    NineBaseResponse response, {
    NineHttpConfig? config,
  }) {
    if (response.code == 401) {
      config?.onTokenError(response);
    }
  }

  static int intFormat(dynamic num, {int def = 0}) {
    if (num == null) return def;
    if (num is String) return int.parse(num);
    return num;
  }
}
