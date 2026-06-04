import 'dart:async';
import 'dart:convert';
import 'package:common/config/api_config.dart';
import 'package:network/base/base_response.dart';

import 'package:base/log/nine_log.dart';
import 'package:network/mg/no_http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabAdsService {
  static final TabAdsService _instance = TabAdsService._internal();
  factory TabAdsService() => _instance;
  TabAdsService._internal();

  final String _cacheKey = 'TabAdsServiceAdsList';
  List<VideoTabModel> _tabAdsList = [];
  Completer? completer;
  bool isRequesting = false;

  void register() {
    initData();
  }

  Future<void> initData() async {
    //添加awit 避免网络请求比本地还快
    await _loadFromCache();
    requestTabAds();
  }

  Future<List<VideoTabModel>> readTabAdsList() async {
    if (_tabAdsList.isEmpty) {
      await requestTabAds();
    }
    await completer?.future;
    return _tabAdsList;
  }

  Future<void> requestTabAds() async {
    if (isRequesting) {
      return;
    }
    completer = Completer();
    isRequesting = true;
    NineBaseResponse response = await NOHttp.instance.post(
      url: ApiConfig.channelAds,
    );
    if (response.isSuccess) {
      try {
        _tabAdsList.clear();
        List<dynamic> list = response.data;
        for (int i = 0; i < list.length; i++) {
          final item = list[i];
          VideoTabModel model = VideoTabModel.fromJson(item);
          _tabAdsList.add(model);
        }

        _saveToCache(list);
      } catch (e) {
        NLog.e("视频tabs异常: $e");
      }
    }
    completer?.complete();
    isRequesting = false;
  }

  /// 保存配置到缓存
  Future<void> _saveToCache(dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(data));
    } catch (e) {
      NLog.e('TabAdsService 保存配置到缓存失败: $e');
    }
  }

  /// 从缓存加载配置
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String configsString = prefs.getString(_cacheKey) ?? '';
      if (configsString.isEmpty) return;
      final valueJson = jsonDecode(configsString) as List;
      List<VideoTabModel> list =
          valueJson.map((json) => VideoTabModel.fromJson(json)).toList();
      _tabAdsList = list;
    } catch (e) {
      NLog.e('TabAdsService 从缓存加载配置失败: $e');
    }
  }
}

class VideoTabModel {
  String d; // channel id
  String t; // tab name
  String tp; // 区分tab和广告
  String url;

  VideoTabModel({this.d = "", this.t = '', this.tp = '', this.url = ''});

  factory VideoTabModel.fromJson(Map<String, dynamic> json) => VideoTabModel(
    d: json['d'] ?? "",
    t: json['t'] ?? "",
    tp: json['tp'] ?? "",
    url: json['url'] ?? "",
  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['d'] = d;
    data['t'] = t;
    data['tp'] = tp;
    data['url'] = url;
    return data;
  }
}
