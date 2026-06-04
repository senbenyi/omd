import 'dart:convert';

import 'package:base/log/nine_log.dart';
import 'package:base/theme/app_theme.dart';
import 'package:base/toast/nine_toast.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config_key.dart';
import 'config_model.dart';
import 'spare_data_config_model.dart';

abstract class BaseConfigService extends GetxService {

  List<ConfigModel> _configs = [];
  void register() {}
  static String configAPi = "/Web/Config2";
  static const String _cacheKey = 'app_configs';
  static const String _cacheTimeKey = 'app_configs_cache_time';

  String appName = "";
  String officialDomain = "";

  /// 获取所有配置列表
  List<ConfigModel> get configs => _configs;

  /// 初始化配置服务
  /// 系统启动时调用此方法
  Future<void> initializeConfigs() async {
    List<ConfigModel>? models = await _loadFromCache();
    if (models != null) {
      _configs = models;
    }

    configAppName();
  }

  void configAppName() {
    ConfigModel? configDataSpareData = getConfigModelByPKey(ConfigKey.SpareData);
    final valueJson = configDataSpareData?.value1;
    if (null != valueJson) {
      Value1 value1 = Value1.fromJson(jsonDecode(valueJson));
      appName = value1.appName ?? appChannel.appName;
      officialDomain = value1.officialDomain ?? "";
    }
  }

  /// 从服务器获取配置数据
  Future<void> fetchConfigsFromServer() async {
    try {
      NineBaseResponse response = await NOHttp.instance.post(
        url: configAPi,
      );
      List list = response.data ?? [];
      List<ConfigModel> listArr =
      list.map((e) => ConfigModel.fromJson(e)).toList();
      _configs = listArr;
      configAppName();
      // 保存到缓存
      _saveToCache(_configs);
    } catch (e) {
      showAppToast("获取服务端配置失败");
      NLog.e('从服务器获取配置失败: $e name: ConfigService');
    }
  }

  /// 根据 ID 获取配置项
  ConfigModel? getConfigModelById(String id) {
    try {
      return _configs.firstWhere((config) => config.id == id);
    } catch (e) {
      NLog.e('未找到 ID 为 $id 的配置项 name: ConfigService');
      return null;
    }
  }

  /// 根据 pKey 获取配置项
  ConfigModel? getConfigModelByPKey(ConfigKey pKey) {
    try {
      ConfigModel configModel = _configs.firstWhere(
            (config) => config.pKey == pKey.name,
      );
      return configModel;
    } catch (e) {
      NLog.e('未找到 pKey 为 $pKey 的配置项 name: ConfigService');
      return null;
    }
  }

  // 分享链接
  void shareUrlShearPlate({
    ConfigKey pKey = ConfigKey.SharedUrl,
    String text = '',
  }) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      showAppToast("分享链接已复制，快去分享吧");
      return;
    }
    BaseInfoModel baseInfoModel = getSpareData();
    if (baseInfoModel.e.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: baseInfoModel.e));
      showAppToast("分享链接已复制，快去分享吧");
      return;
    }
    int index = _configs.indexWhere((config) => config.pKey == pKey.name);
    if (index == -1) return;
    ConfigModel configModel = _configs[index];
    if (configModel.value1.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: configModel.value1));
      showAppToast("分享链接已复制，快去分享吧");
    }
  }

  /// 根据 pKey 获取配置值（返回 value1）
  String? getConfigValueByPKey(ConfigKey pKey) {
    final config = getConfigModelByPKey(pKey);
    return config?.value1;
  }

  String getShareUrl({String userId = ""}) {
    String url = getConfigValueByPKey(ConfigKey.SharedUrl) ?? "";
    BaseInfoModel baseInfoModel = getSpareData();
    if (baseInfoModel.d.isNotEmpty) url = baseInfoModel.d;
    if (userId.isNotEmpty) {
      url = "$url?inviteCode=$userId";
    }
    return url;
  }

  /// 根据 pKey 获取多个配置值
  Map<String, String?> getConfigValuesByPKey(ConfigKey pKey) {
    final config = getConfigModelByPKey(pKey);
    if (config == null) return {};

    return {
      'value1': config.value1,
      'value2': config.value2,
      'value3': config.value3,
      'value4': config.value4,
      'value5': config.value5,
    };
  }

  /// 获取多个指定 pKey 的配置项
  List<ConfigModel> getConfigModelsByPKeys(List<String> pKeys) {
    return _configs
        .where((config) => config.pKey != null && pKeys.contains(config.pKey))
        .toList();
  }

  /// 保存配置到缓存
  Future<void> _saveToCache(List<ConfigModel> configs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configsJson = configs.map((config) => config.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(configsJson));
      await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      NLog.e('配置已保存到缓存 的配置项 name: ConfigService');
    } catch (e) {
      NLog.e('保存配置到缓存失败: $e 的配置项 name: ConfigService');
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
      NLog.e('从缓存加载配置失败: $e 的配置项 name: ConfigService');
      return null;
    }
  }

  /// 清除缓存
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimeKey);
      NLog.e('配置缓存已清除 name: ConfigService');
    } catch (e) {
      NLog.e('清除配置缓存失败: $e name: ConfigService');
    }
  }

  /// 黄瓜 杏吧 狐狸 豆花 app 配置
  BaseInfoModel getSpareData() {
    SpareDataConfigModel entity = getSpareDataConfig();
    if (entity.baseInfo.isEmpty) return BaseInfoModel();
    String rs = appChannel.kiwiRs;
    int index = entity.baseInfo.indexWhere((e) => e.i == rs);
    if (index == -1) return BaseInfoModel();
    return entity.baseInfo[index];
  }

  /// 黄瓜 杏吧 狐狸 豆花 app 配置
  SpareDataConfigModel getSpareDataConfig() {
    ConfigModel? spareData = getConfigModelByPKey(ConfigKey.SpareData);
    ConfigModel config = spareData ?? ConfigModel();
    String value = config.value1;
    if (value.isEmpty) return SpareDataConfigModel();
    final json = jsonDecode(value);
    return SpareDataConfigModel.fromJson(json);
  }

  /// 黄瓜 杏吧 狐狸 豆花 app 配置
  BaseInfoModel get baseInfoModel {
    SpareDataConfigModel config = getSpareDataConfig();
    BaseInfoModel entity = getSpareData();
    if (entity.i.isNotEmpty) return entity;
    return BaseInfoModel(
      b: config.appName,
      f: config.email,
      d: config.officialDomain,
      e: config.brandDomain,
    );
  }
}


class Value1 {
  String? email;
  List<String>? domains;
  String? tG;
  String? qR;
  String? officialDomain;
  String? appName;

  Value1({
    this.email,
    this.domains,
    this.tG,
    this.qR,
    this.officialDomain,
    this.appName,
  });

  Value1.fromJson(Map<String, dynamic> json) {
    email = json['Email'];
    domains = json['Domains'].cast<String>();
    tG = json['TG'];
    qR = json['QR'];
    officialDomain = json['OfficialDomain'];
    appName = json['AppName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Email'] = email;
    data['Domains'] = domains;
    data['TG'] = tG;
    data['QR'] = qR;
    data['OfficialDomain'] = officialDomain;
    data['AppName'] = appName;
    return data;
  }
}