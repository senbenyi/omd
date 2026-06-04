import 'dart:typed_data';
import 'package:common/imagewidget/decryptor/decryptor.dart';
import 'package:cryptography/cryptography.dart';
import 'dart:convert';

class NineDecrypterNew {
  // AES key 和 IV
  static final _keyBytes = utf8.encode("gFzviOY0zOxVq1cu");
  static final _ivBytes = utf8.encode("ZmA0Osl677UdSrl0");

  // AES-CBC 算法实例
  static final _algorithm = AesCbc.with128bits(
    macAlgorithm: MacAlgorithm.empty, // CBC 不需要 MAC
    paddingAlgorithm: PaddingAlgorithm.pkcs7,
  );

  /// 解密图像字节
  static Future<Uint8List?> decryptImageData(
    Uint8List bytes, {
    String url = "",
    String? title,
  }) async {
    try {
      Uint8List newBytes = await _decryptBytes(bytes);
      // NLog.d('解密成功$url');
      return newBytes;
    } catch (e) {
      // NLog.e('解密失败$url  原始bytes长度:${bytes.length}}');
      // NLog.e('解密失败$url  error:${e.toString()}');
      Uint8List newBytes = await Decryptor.decryptImageData(bytes);
      return newBytes;
    }
  }

  /// 核心解密逻辑
  static Future<Uint8List> _decryptBytes(Uint8List bytes) async {
    // 1. 转成 SecretKey
    final secretKey = SecretKey(_keyBytes);

    // 2. 构造 SecretBox
    // cryptography_flutter 的 AES-CBC 解密需要 SecretBox
    final secretBox = SecretBox(
      bytes,
      nonce: _ivBytes,
      mac: Mac.empty, // CBC 模式不需要 MAC
    );

    // 3. 解密
    final decrypted = await _algorithm.decrypt(secretBox, secretKey: secretKey);
    final decoded = base64.decode(utf8.decode(decrypted));

    return Uint8List.fromList(decoded);
  }
}
