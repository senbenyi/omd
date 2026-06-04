import 'package:base/theme/app_theme.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';
import 'package:common/config/api_config.dart';
import 'package:base/log/nine_log.dart';
import 'package:base/utils/string_util.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CryptoUtil {
  CryptoUtil._internal();

  static final key = Key.fromUtf8("gFzviOY0zOxVq1cu");
  static final iv = IV.fromUtf8("ZmA0Osl677UdSrl0");

  //Decrypt data
  static String decrypt(String text) {
    try {
      // final key = Key.fromUtf8(Env.envConfig.key);
      // final iv = IV.fromUtf8(Env.envConfig.iv);

      final encrypt = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
      return encrypt.decrypt(Encrypted.fromBase64(text), iv: iv);
    } catch (err) {
      return "Error decrypt";
    }
  }

  //Encrypt data
  static String encrypt(String plainText) {
    try {
      // final key = Key.fromUtf8(Env.envConfig.key);
      // final iv = IV.fromUtf8(Env.envConfig.iv);
      final encrypt = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
      return encrypt.encrypt(plainText, iv: iv).base64;
    } on Exception catch (_) {
      return "Error encrypt";
    }
  }

  //d095edb720134665a697e27a25138b7f.jpg.js,31a752df9bfa4c5e8069b30ea73f6329.jpg.js,9691abd45fdc416c92368feded6f9479.jpg.js
  // 处理图片解密
  static Future<Uint8List> fetchAndDecrypt(String? url) async {
    if (StringUtil.isEmpty(url)) return Uint8List(0);
    try {
      final response = await http.get(
        Uri.parse("${appChannel.videoDomain}$url"),
      );
      final arrayBuffer = response.bodyBytes;

      // 尝试将 ArrayBuffer 转换为字符串
      final decodedString = utf8.decode(arrayBuffer, allowMalformed: true);
      Uint8List decryptedContent;
      if (isBase64(decodedString)) {
        // 如果是 Base64 编码，直接解密
        decryptedContent = decryptBase64Data(decodedString);
      } else {
        // 如果是二进制字节，先转换为 Base64 再解密
        final base64Data = arrayBufferToBase64(arrayBuffer);
        decryptedContent = decryptBase64Data(base64Data);
      }
      // 返回解密后的数据
      return decryptedContent;
    } catch (error) {
      NLog.e('解密数据失败:$url - $error');
      rethrow;
    }
  }

  static Future<List<Uint8List>> fetchAndDecryptMulti(String? url) async {
    List<Uint8List> list = [];
    if (StringUtil.isEmpty(url)) return list;

    if (url!.contains(",")) {
      final imgs = url.split(",");
      for (int i = 0; i < imgs.length; i++) {
        final result = await fetchAndDecrypt(imgs[i]);
        list.add(result);
      }
    }
    return list;
  }

  // 处理有声文件解密
  static Future<Uint8List> fetchAndDecryptAudio(String url) async {
    try {
      final response = await http.get(
        Uri.parse("${appChannel.videoDomain}$url"),
      );
      final arrayBuffer = response.bodyBytes;

      // 尝试将 ArrayBuffer 转换为字符串
      final decodedString = utf8.decode(arrayBuffer, allowMalformed: true);

      Uint8List decryptedContent;

      if (isBase64(decodedString)) {
        // 如果是 Base64 编码，直接解密
        decryptedContent = decryptBase64Data(decodedString);
      } else {
        // 如果是二进制字节，先转换为 Base64 再解密
        final base64Data = arrayBufferToBase64(arrayBuffer);
        decryptedContent = decryptBase64Data(base64Data);
      }

      // 返回解密后的数据
      return decryptedContent;
    } catch (error) {
      print('解密数据失败:$url - $error');
      rethrow;
    }
  }

  static String arrayBufferToBase64(Uint8List buffer) {
    return base64Encode(buffer);
  }

  static Uint8List decryptBase64Data(String base64Data) {
    try {
      final encryter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

      final decryptedText = encryter.decrypt64(base64Data, iv: iv);
      return base64Decode(decryptedText);
    } catch (e) {
      print('解密Base64数据失败: $e');
      rethrow;
    }
  }

  // ({String fileName, String mimeType}) _extractFileInfo(String url) {
  //   final fileName = url.substring(url.lastIndexOf('/') + 1);
  //   final extension = fileName.contains('.') ? fileName.split('.').last : 'jpg';
  //   final mimeType = _getMimeType('.$extension');
  //   return (fileName: fileName, mimeType: mimeType);
  // }

  /// 解密 Base64 字符串（AES-CBC + PKCS7）
  static Uint8List decryptBase64(String base64Str) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    return Uint8List.fromList(
      encrypter.decryptBytes(Encrypted.from64(base64Str), iv: iv),
    );
  }

  /// 判断是否是 Base64 字符串
  static bool isBase64(String str) {
    try {
      final decoded = base64Decode(str);
      final reEncoded = base64Encode(decoded);
      return reEncoded == str;
    } catch (_) {
      return false;
    }
  }

  /// 解密原始二进制 Uint8List 数据（会先转为 Base64）
  static Uint8List decryptBytes(Uint8List encryptedBytes) {
    final base64Str = arrayBufferToBase64(encryptedBytes);
    return decryptBase64(base64Str);
  }

  static Future<Uint8List> getImageAsBytes(String assetPath) async {
    // 1. 读取图片为二进制
    ByteData byteData = await rootBundle.load(assetPath);
    Uint8List bytes = byteData.buffer.asUint8List();
    return bytes;

    // 2. 解码获取图片大小
    // ui.Codec codec = await ui.instantiateImageCodec(bytes);
    // ui.FrameInfo frameInfo = await codec.getNextFrame();
    // ui.Image image = frameInfo.image;
    //
    // print('图片宽度: ${image.width}');
    // print('图片高度: ${image.height}');
  }

  // 处理视频解密
  static String generateAuthUrl(
    String domain,
    String uri, [
    String key = 'wB760Vqpk76oRSVA1TNz',
  ]) {
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final temp = '$key/$uri$timestamp';
    final sign = md5.convert(utf8.encode(temp)).toString().toLowerCase();
    final baseUrl = uri.contains('http') ? uri : domain + uri;
    return '$baseUrl?sign=$sign&t=$timestamp';
  }

  // /// 处理视频解密
  // static String generateAuthUrl(
  //   String domain,
  //   String uri, {
  //   String key = 'wB760Vqpk76oRSVA1TNz',
  // }) {
  //   final timestamp =
  //       (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
  //   final temp = '$key/$uri$timestamp';
  //   final bytes = utf8.encode(temp);
  //   final digest = crypto.md5.convert(bytes);
  //   final sign = digest.toString().toLowerCase();
  //   final baseUrl = uri.startsWith('http') ? uri : domain + uri;
  //   return '$baseUrl?sign=$sign&t=$timestamp';
  // }
  //
}
