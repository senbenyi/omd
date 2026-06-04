// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:network/base/base_response.dart';

const int UNAUTHORIZED = 401;
const int FORBIDDEN = 403;
const int NOT_FOUND = 404;
const int REQUEST_TIMEOUT = 408;
const int TOO_MANY_REQUESTS = 429;
const int INTERNAL_SERVER_ERROR = 500;
const int BAD_GATEWAY = 502;
const int SERVICE_UNAVAILABLE = 503;
const int GATEWAY_TIMEOUT = 504;

class NineErrorHandle {
  static NineBaseResponse handleDioException(DioException error) {
    String message = "";
    int statusCode = 0;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = "网络连接超时，请检查网络设置";
      case DioExceptionType.sendTimeout:
        message = "网络请求超时，请检查网络设置";
      case DioExceptionType.receiveTimeout:
        message = "服务器响应超时，请稍后重试";
      case DioExceptionType.connectionError:
        message = "网络连接错误，请检查网络连接";
      case DioExceptionType.badResponse:
        {
          int? errCode = error.response?.statusCode;
          statusCode = errCode ?? 0;
          switch (errCode) {
            case 400:
              message = "请求语法错误";
            case UNAUTHORIZED:
              message = "未完成用户认证，没有权限";
            case FORBIDDEN:
              message = "服务器拒绝执行";
            case NOT_FOUND:
              message = "无法连接服务器";
            case REQUEST_TIMEOUT:
              message = "请求超时";
            case TOO_MANY_REQUESTS:
              message = "请求过于频繁，请稍后重试";
            case INTERNAL_SERVER_ERROR:
              message = "服务器内部错误";
            case BAD_GATEWAY:
              message = "网关错误";
            case SERVICE_UNAVAILABLE:
              message = "服务器暂时不可用";
            case GATEWAY_TIMEOUT:
              message = "网关超时";
            case 505:
              message = "不支持HTTP协议请求";
            default:
              message = _messageFromResponseBody(error.response?.data) ??
                  error.response?.statusMessage ??
                  '未知错误';
          }
        }
      case DioExceptionType.cancel:
        message = "请求已取消";
      case DioExceptionType.unknown:
        message = "网络请求发生未知错误";
      default:
        message = error.message?.toString() ?? '网络请求失败';
    }
    return NineBaseResponse(
      data: null,
      code: statusCode > 0 ? statusCode : -1,
      statusCode: statusCode,
      message: message,
      error: error,
    );
  }

  static String? _messageFromResponseBody(dynamic data) {
    if (data == null) return null;
    try {
      final Map<String, dynamic> json;
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is! Map) return null;
        json = Map<String, dynamic>.from(decoded);
      } else if (data is Map) {
        json = Map<String, dynamic>.from(data);
      } else {
        return null;
      }
      final msg = json['message'];
      if (msg != null && msg.toString().isNotEmpty) {
        return msg.toString();
      }
    } catch (_) {}
    return null;
  }

  static bool shouldRetry(dynamic error) {
    if (error is SocketException || error is TimeoutException) {
      return true;
    }
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
        case DioExceptionType.unknown:
          return true;
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          return statusCode != null &&
              (statusCode >= 500 || statusCode == 408 || statusCode == 429);
        default:
          return false;
      }
    }
    return false;
  }

  static bool shouldChangeDomian(dynamic error) {
    if (error is SocketException) {
      return true;
    }
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.badResponse ||
          error.type == DioExceptionType.unknown) {
        return true;
      }
    }
    return false;
  }
}
