import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:base/log/nine_log.dart';
import 'package:unique_identifier/unique_identifier.dart';

class UuidService {
  static const String _uuidKey = 'app_uuid';
  static AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);
  static FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static String _currentDeviceID = "";
  static String get currentDeviceID => _currentDeviceID;

  /// 获取或生成UUID
  static Future<void> getOrCreateUuid() async {
    if (Platform.isAndroid) {
      _secureStorage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    }
    try {
      String storedUuid = await _secureStorage.read(key: _uuidKey) ?? "";
      if (storedUuid.isNotEmpty) {
        _currentDeviceID = storedUuid;
      }
    } catch (e) {
      NLog.e("设备ID读取错误:$e");
    }
    if (_currentDeviceID.isEmpty) {
      if (Platform.isAndroid) {
        _currentDeviceID = await getAndioid();
      } else {
        _currentDeviceID = await getIos();
      }
      try {
        await _secureStorage.write(key: _uuidKey, value: _currentDeviceID);
      } catch (e) {
        NLog.e("设备ID保存错误:$e");
      }
      NLog.d("自研生成设备：$_currentDeviceID");
    }
  }

  static Future<String> getIos() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo info = await deviceInfo.iosInfo;
    String deviceId = info.identifierForVendor ?? '';
    return deviceId;
  }

  static Future<String> getAndioid() async {
    String deviceId = (await UniqueIdentifier.serial)!;
    return deviceId;
  }
}
