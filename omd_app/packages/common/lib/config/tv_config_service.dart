import 'dart:developer';
import 'dart:convert';
import 'package:common/config/config_key.dart';
import 'package:common/config/config_model.dart';
import 'package:network/network.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TvConfigService {
  static final _instanceSingle = TvConfigService._internal();
  factory TvConfigService() => _instanceSingle;
  static TvConfigService get instance => TvConfigService();
  TvConfigService._internal() : super();

  static const String _cacheKey = 'app_configs';
  static String configAPi = "/Web/Config2";
  String appName = "";
  String officialDomain = "";
  List<ConfigModel> get configs => _configs;
  List<ConfigModel> _configs = [];

  Future<void> initializeConfigs() async {
    List<ConfigModel>? models = await _loadFromCache();
    if (models != null) {
      _configs = models;
    }
    configAppName();
  }

  void configAppName() {
    ConfigModel? configDataSpareData = getConfigModelByPKey(
      ConfigKey.SpareData,
    );
    if (configDataSpareData == null) {
      log('未找到 SpareData 配置项', name: 'ConfigService');
      return;
    }
    if (configDataSpareData.value1.isNotEmpty) {
      try {
        Map<String, dynamic> valueJson = jsonDecode(configDataSpareData.value1);
        appName = valueJson['AppName'] ?? "91漫画官方";
        officialDomain = valueJson['OfficialDomain'] ?? "www.91mh002.vip";
      } catch (e) {
        log('解析 SpareData 配置项失败: $e', name: 'ConfigService');
      }
    }
  }

  Future<void> fetchConfigsFromServer() async {
    try {
      NineBaseResponse response = await NOHttp.instance.post(url: configAPi);
      List list = response.data ?? [];
      List<ConfigModel> listArr =
          list.map((e) => ConfigModel.fromJson(e)).toList();
      _configs = listArr;
      configAppName();
      // 保存到缓存
      _saveToCache(_configs);
    } catch (e) {
      showAppToast("获取服务端配置失败");
      log('从服务器获取配置失败: $e', name: 'ConfigService');
    }
  }

  ConfigModel? getConfigModelByPKey(ConfigKey pKey) {
    try {
      ConfigModel configModel = _configs.firstWhere(
        (config) => config.pKey == pKey.name,
      );
      return configModel;
    } catch (e) {
      log('未找到 pKey 为 $pKey 的配置项', name: 'ConfigService');
      return null;
    }
  }

  /// 根据 pKey 获取配置值（返回 value1）

  String? getConfigValueByPKey(ConfigKey pKey) {
    final config = getConfigModelByPKey(pKey);
    return config?.value1;
  }

  /// 保存配置到缓存
  Future<void> _saveToCache(List<ConfigModel> configs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configsJson = configs.map((config) => config.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(configsJson));

      log('配置已保存到缓存', name: 'ConfigService');
    } catch (e) {
      log('保存配置到缓存失败: $e', name: 'ConfigService');
    }
  }

  /// 从缓存加载配置
  Future<List<ConfigModel>?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configsString = prefs.getString(_cacheKey);

      if (configsString == null) return null;

      final configsJson = jsonDecode(configsString) as List;
      return configsJson.map((json) => ConfigModel.fromJson(json)).toList();
    } catch (e) {
      log('从缓存加载配置失败: $e', name: 'ConfigService');
      return null;
    }
  }

  /// 清除缓存
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);

      log('配置缓存已清除', name: 'ConfigService');
    } catch (e) {
      log('清除配置缓存失败: $e', name: 'ConfigService');
    }
  }
}
