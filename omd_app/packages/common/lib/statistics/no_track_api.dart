import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:base/log/nine_log.dart';

class NoTrackApi {
  static String launchTrakApi = '/AppInstall/startup';
  static String onLineTimeTrakApi = '/AppInstall/refresh';
  static String uploadLaunchSccess = "/Web/GetDevice";
  static String uploadLaunchFail = "/Web/GetDeviceLog";

  //上报启动
  static Future<String> uploadLaunch({
    required bool isFirst,
    required String appCode,
    required String channelCode,
    required String deviceId,
    required String domain,
  }) async {
    final payload = {
      'first': isFirst,
      'deviceId': deviceId,
      'platform': Platform.isAndroid ? 10 : 20, // Android=10, iOS=20
      'appCode': appCode,
      'channelCode': channelCode,
    };
    String err = "";
    final url = '$domain$launchTrakApi';
    try {
      log("请求：$url: $payload");
      final response = await Dio().post(
        url,
        options: getOptions(),
        data: jsonEncode(payload),
      );
      if (response.statusCode != 200) {
        err = response.statusMessage ?? "";
      }
      log("返回：$url : ${response.data}");
    } catch (e) {
      log("$url :$e", isError: true);
      err = e.toString();
    }
    return err;
  }

  //上报在线时长
  static Future<void> uploadOnlineTime({
    required String appCode,
    required String totalSeconds,
    required String deviceId,
    required String domain,
  }) async {
    final payload = {
      'deviceId': deviceId,
      'ActiveSeconds': totalSeconds,
      'appCode': appCode,
    };
    final url = '$domain$onLineTimeTrakApi';
    log("请求：url:$url 参数:$payload");
    try {
      final response = await Dio().post(
        url,
        options: getOptions(),
        data: jsonEncode(payload),
      );
      log("返回$url :${response.data}");
    } catch (e) {
      log("$url :$e", isError: true);
    }
  }

  //上报成功
  static Future<void> upLoadTrackFail({required String errMessage}) async {
    // log(
    //   "请求：$uploadLaunchFail PlatForm: ${Platform.isAndroid ? 10 : 20} Msg:$errMessage",
    // );
    // NineBaseResponse response = await NOHttp.instance.post(
    //   url: uploadLaunchFail,
    //   params: {"PlatForm": Platform.isAndroid ? 10 : 20, "Msg": errMessage},
    //   needRequetEncry: true,
    // );
    // log("返回：$uploadLaunchFail ${response.data}");
  }

  static Future<void> upLoadTrackSuccess() async {
    // log("请求：$uploadLaunchSccess PlatForm: ${Platform.isAndroid ? 10 : 20}");
    // NineBaseResponse response = await NOHttp.instance.post(
    //   url: uploadLaunchSccess,
    //   params: {"PlatForm": Platform.isAndroid ? 10 : 20},
    //   needRequetEncry: true,
    // );
    // log("返回：$uploadLaunchSccess ${response.data}");
  }

  static Options getOptions() {
    Options options = Options(
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      },
    );
    return options;
  }

  static void log(dynamic message, {bool isError = false}) {
    if (isError) {
      NLog.e("自研统计: $message");
    } else {
      NLog.d("自研统计: $message");
    }
  }
}
