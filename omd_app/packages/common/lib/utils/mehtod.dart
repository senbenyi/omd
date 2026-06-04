import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:image_picker/image_picker.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timeago/timeago.dart';
import 'package:crypto/crypto.dart';

class Method {
  Method._();

  static String convertMD5(String data) {
    var content = const Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    var text = HEX.encode(digest.bytes);
    return text;
  }

  static String convertSha256(String data) {
    var content = const Utf8Encoder().convert(data);
    var digest = sha256.convert(content);
    var text = HEX.encode(digest.bytes);
    return text;
  }

  static String getDateTime() {
    DateTime dateTime = DateTime.now();
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  static String durationToTime(dynamic value) {
    double durations = 0;
    if (value is String) {
      durations = double.parse(value);
    }
    if (value is int) {
      durations = double.parse(value.toString());
    }
    double hours = durations.floor() / 3600;
    double forMinutes = durations % 3600;
    double minutes = forMinutes.floor() / 60;
    double sec = forMinutes.ceil() % 60;

    String hoursString = hours.round().toString();
    String minutesString =
        minutes.round() < 10
            ? "0${minutes.round()}"
            : minutes.round().toString();
    String secString = sec < 10 ? "0${sec.round()}" : sec.round().toString();
    if (durations < 3600) {
      return '$minutesString:$secString';
    } else {
      return '$hoursString:$minutesString:$secString';
    }
  }

  static Map<String, int> retryCountMap = {};
  static List<List> tasks = [];
  static List<bool> wdsRunningStatuses = List.generate(5, (index) => false);

  static String randomId(int range) {
    String str = "";
    List<String> arr = [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l",
      "m",
      "n",
      "o",
      "p",
      "q",
      "r",
      "s",
      "t",
      "u",
      "v",
      "w",
      "x",
      "y",
      "z",
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z",
    ];
    for (int i = 0; i < range; i++) {
      int pos = Random().nextInt(arr.length - 1);
      str += arr[pos];
    }
    return str;
  }

  static Future<bool> isFileSizeGreaterThan1MB(String filePath) async {
    File file = File(filePath);
    XFile webFile = XFile(filePath);
    int fileSizeInBytes;

    if (kIsWeb) {
      fileSizeInBytes = await webFile.length();
      double fileSizeInMB =
          fileSizeInBytes / (1024 * 1024); // Convert bytes to megabytes
      // print(">>>File size ${fileSizeInMB}");
      return fileSizeInMB > 1;
    } else {
      if (await file.exists()) {
        fileSizeInBytes = await file.length();
        double fileSizeInMB =
            fileSizeInBytes / (1024 * 1024); // Convert bytes to megabytes
        // print(">>>File size ${fileSizeInMB}");
        return fileSizeInMB > 100;
      }
    }
    return false; // File doesn't exist
  }

  // validate file size
  static Future<bool> isFileSizeGreaterThan500MB(String filePath) async {
    File file = File(filePath);
    XFile webFile = XFile(filePath);
    int fileSizeInBytes;

    if (kIsWeb) {
      fileSizeInBytes = await webFile.length();
      double fileSizeInMB =
          fileSizeInBytes / (1024 * 1024); // Convert bytes to megabytes);
      return fileSizeInMB > 500;
    } else {
      if (await file.exists()) {
        fileSizeInBytes = await file.length();
        double fileSizeInMB =
            fileSizeInBytes / (1024 * 1024); // Convert bytes to megabytes
        return fileSizeInMB > 500;
      }
    }
    return false; // File doesn't exist
  }

  static String formatAgo(String? createdTime) {
    if (createdTime == null || createdTime.isEmpty) {
      return '现在';
    }
    final createdDate = DateTime.parse(createdTime);
    setLocaleMessages('zh_CN', CustomAgoMessages());
    String readableTime = format(
      createdDate,
      locale: 'zh_CN',
      allowFromNow: false,
    );
    return readableTime;
  }

  //Copy to clipboard
  static void copyClipboard(String copyText) {
    Clipboard.setData(ClipboardData(text: copyText))
        .then((value) {
          showAppToast('已复制');
        })
        .catchError((error) {
          // Handle error if any
          print('Error copying to clipboard: $error');
        });
  }

  static void checkPermissionCamera({
    VoidCallback? afterPermissionAllow,
  }) async {
    await Permission.camera.request();
    PermissionStatus storageStatus = await Permission.camera.status;
    if (storageStatus == PermissionStatus.denied) {
      await openAppSettings();
    } else if (storageStatus == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
      return;
    } else {
      afterPermissionAllow!.call();
    }
  }
}

class CustomAgoMessages implements LookupMessages {
  @override
  String prefixAgo() => '';

  @override
  String prefixFromNow() => '';

  @override
  String suffixAgo() => '';

  @override
  String suffixFromNow() => '';

  @override
  String lessThanOneMinute(int seconds) => ' 现在';

  @override
  String aboutAMinute(int minutes) => '现在';

  @override
  String minutes(int minutes) => '$minutes 分钟前';

  @override
  String aboutAnHour(int minutes) => '$minutes 分钟前';

  @override
  String hours(int hours) => '$hours 小时前';

  @override
  String aDay(int hours) => '一天前';

  @override
  String days(int days) => '$days 天前';

  @override
  String aboutAMonth(int days) => '一个月前';

  @override
  String months(int months) => '$months 个月前';

  @override
  String aboutAYear(int year) => '一年前';

  @override
  String years(int years) => '$years 年以前';

  @override
  String wordSeparator() => ' ';
}

class VersionComparator {
  /// 比较两个版本号的大小
  /// 返回值：
  /// - 1 表示 [version1] 大于 [version2]
  /// - 0 表示 [version1] 等于 [version2]
  /// - -1 表示 [version1] 小于 [version2]
  static int compare(String version1, String version2) {
    List<int> parts1 = _parseVersion(version1);
    List<int> parts2 = _parseVersion(version2);
    int length = parts1.length > parts2.length ? parts1.length : parts2.length;
    for (int i = 0; i < length; i++) {
      int v1 = i < parts1.length ? parts1[i] : 0;
      int v2 = i < parts2.length ? parts2[i] : 0;
      if (v1 > v2) {
        return 1;
      } else if (v1 < v2) {
        return -1;
      }
    }
    return 0;
  }

  /// 将版本号字符串解析为整数列表，例如 "1.2.3" 解析为 [1, 2, 3]
  static List<int> _parseVersion(String version) {
    return version.split('.').map((part) => int.parse(part)).toList();
  }
}
