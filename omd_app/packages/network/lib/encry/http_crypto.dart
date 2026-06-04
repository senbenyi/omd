import 'dart:convert';
import 'dart:typed_data';

import 'package:base/log/nine_log.dart';
import 'package:encrypt/encrypt.dart';

class HttpCrypto {
  HttpCrypto._internal();

  static final key = Key.fromUtf8("gFzviOY0zOxVq1cu");
  static final iv = IV.fromUtf8("ZmA0Osl677UdSrl0");

  static String decrypt(String text) {
    try {
      final encrypt = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
      return encrypt.decrypt(Encrypted.fromBase64(text), iv: iv);
    } catch (err) {
      return "Error decrypt";
    }
  }

  static String encrypt(String plainText) {
    try {
      final encrypt = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
      return encrypt.encrypt(plainText, iv: iv).base64;
    } on Exception catch (_) {
      return "Error encrypt";
    }
  }

  static Uint8List decryptBase64Data(String base64Data) {
    try {
      final encryter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
      final decryptedText = encryter.decrypt64(base64Data, iv: iv);
      return base64Decode(decryptedText);
    } catch (e) {
      NLog.d('解密Base64数据失败: $e');
      rethrow;
    }
  }

  static bool isBase64(String str) {
    try {
      final decoded = base64Decode(str);
      final reEncoded = base64Encode(decoded);
      return reEncoded == str;
    } catch (_) {
      return false;
    }
  }
}
