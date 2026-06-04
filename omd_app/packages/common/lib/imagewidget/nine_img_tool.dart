import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:base/log/nine_log.dart';

void imgeLogD(String message) {
  // NLog.d("IMAGE>>>>", message);
}

void imgeLogE(String message) {
  NLog.e("IMAGE>>>>", message);
}

enum ImageType { adGif, viedeoGif, static }

class NineImageTool {
  static String md5Str(String url) {
    // 将字符串转为 UTF8 bytes
    List<int> bytes = utf8.encode(url);
    // 计算 MD5
    String md5Str = md5.convert(bytes).toString();
    return md5Str;
  }
}
