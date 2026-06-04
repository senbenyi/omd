import 'package:shared_preferences/shared_preferences.dart';

class SharedStorageUtil {
  static final SharedStorageUtil _instance = SharedStorageUtil._internal();
  factory SharedStorageUtil() => _instance;

  SharedStorageUtil._internal();

  static SharedPreferences? _prefs;

  static Future init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<bool> setString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  static String getString(String key, [String defValue = '']) {
    return _prefs!.getString(key) ?? defValue;
  }

  static Future<bool> setInt(String key, int value) async {
    return await _prefs!.setInt(key, value);
  }

  static int getInt(String key, [int defValue = 0]) {
    return _prefs!.getInt(key) ?? defValue;
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }

  static bool getBool(String key, [bool defValue = false]) {
    return _prefs!.getBool(key) ?? defValue;
  }

  static Future<bool> setDouble(String key, double value) async {
    return await _prefs!.setDouble(key, value);
  }

  static double getDouble(String key, [double defValue = 0.0]) {
    return _prefs!.getDouble(key) ?? defValue;
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs!.setStringList(key, value);
  }

  static List<String> getStringList(String key, [List<String>? defValue]) {
    return _prefs!.getStringList(key) ?? defValue ?? [];
  }

  /// 删除指定 key
  static Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }

  /// 清空所有缓存
  static Future<bool> clear() async {
    return await _prefs!.clear();
  }

  /// 判断是否包含 key
  static bool contains(String key) {
    return _prefs!.containsKey(key);
  }
}