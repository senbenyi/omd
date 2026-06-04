import 'dart:convert' as convert;
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:base/log/nine_log.dart';

/// A utility class for handling image decryption
class Decryptor {
  static final _key = encrypt.Key.fromUtf8("gFzviOY0zOxVq1cu");
  static final _iv = encrypt.IV.fromUtf8("ZmA0Osl677UdSrl0");

  /// Decrypts image data using AES with optimized performance
  static Future<Uint8List> decryptImageData(Uint8List bytes) async {
    try {
      // NLog.d('[TVNF-Decryptor]', '=图像解密=开始解密，数据大小: ${bytes.length} bytes');

      // 尝试直接解密
      try {
        return _decryptBytes(bytes);
      } catch (e) {
        NLog.d('[TVNF-Decryptor]', '=图像解密=直接解密失败，尝试Base64处理: $e');

        // 如果直接解密失败，尝试 Base64 处理
        final decodedString = convert.utf8.decode(bytes, allowMalformed: true);
        if (_isBase64(decodedString)) {
          return _decryptBase64String(decodedString);
        } else {
          return _decryptBase64String(convert.base64Encode(bytes));
        }
      }
    } catch (e) {
      NLog.e('[TVNF-Decryptor]', '=图像解密=Image decryption failed: $e');
      rethrow;
    }
  }

  /// 判断是否是 Base64 字符串
  static bool _isBase64(String str) {
    try {
      final decoded = convert.base64Decode(str);
      final reEncoded = convert.base64Encode(decoded);
      return reEncoded == str;
    } catch (_) {
      return false;
    }
  }

  /// 解密字节数据
  static Uint8List _decryptBytes(Uint8List bytes) {
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );

    final base64Data = convert.base64Encode(bytes);
    final decryptedText = encrypter.decrypt64(base64Data, iv: _iv);
    return convert.base64Decode(decryptedText);
  }

  /// 解密 Base64 字符串
  static Uint8List _decryptBase64String(String base64Data) {
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );

    final decryptedText = encrypter.decrypt64(base64Data, iv: _iv);
    return convert.base64Decode(decryptedText);
  }
}
