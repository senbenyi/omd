import 'dart:convert';

import 'package:base/log/nine_log.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:network/base/base_response.dart';
import 'package:network/mg/nine_http_instance.dart';

class NineDomianTool {
  static String aesKey = "gFzviOY0zOxVq1cu";
  static String aesIV = "ZmA0Osl677UdSrl0";

  static Future<bool> check({required String domain}) async {
    NLog.d("开始域名检测：$domain");
    NineBaseResponse response = await NineHttpInstance().request(
      url: "/Web/Config",
      domain: domain,
      requesNeedEncryped: false,
      responseIsEncryped: true,
    );
    NLog.d(
      "域名检测：$domain ${response.code == 200 ? "成功" : "失败"} code:${response.code} message:${response.message}",
    );
    return response.code == 200;
  }

  static Future<Response> checkWebUrl({required String domain}) async {
    final dio = Dio();
    Response response = await dio.get(domain);
    return response;
  }

  static Future<List<String>> requestDomainList(String rootUrl) async {
    final dio = Dio();
    final url = "$rootUrl/Web/HostList2";
    try {
      FormData formData = FormData.fromMap({"MGHostType": "4"});
      final response = await dio.post(
        url,
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );
      if (response.data == null) return [];
      late String encryptedString;
      if (response.data is String) {
        encryptedString = response.data;
      } else if (response.data is List<int>) {
        encryptedString = String.fromCharCodes(response.data);
      } else {
        return [];
      }

      final decryptedString = decryptAES(encryptedString);
      String str = decryptedString.trim();
      if (str.startsWith('"') && str.endsWith('"')) {
        str = str.substring(1, str.length - 1);
      }
      Map<String, dynamic> map = jsonDecode(str);
      final List<String> domains = [];

      final data = map['data'];
      if (data is Map) {
        final items = data['items'];
        if (items is List) {
          for (final item in items) {
            if (item is Map &&
                item['domain'] is String &&
                item['domain'].isNotEmpty) {
              domains.add(item['domain']);
            }
          }
        }
      }
      return domains;
    } catch (e) {
      NLog.d("[TVNF] requestDomainList error: $e");
      return [];
    }
  }

  static String decryptAES(String encryptedBase64) {
    try {
      final encryptedBytes = base64Decode(encryptedBase64);
      final key = Key.fromUtf8(aesKey);
      final iv = IV.fromUtf8(aesIV);

      final encrypter = Encrypter(
        AES(key, mode: AESMode.cbc, padding: 'PKCS7'),
      );

      final encrypted = Encrypted(encryptedBytes);
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      NLog.d("[TVNF] AES 解密失败: $e");
      return encryptedBase64;
    }
  }
}
