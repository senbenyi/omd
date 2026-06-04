import 'dart:async';
import 'package:common/config/mg_config_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:base/device/network_listener.dart';
import 'package:base/theme/app_theme.dart';
import 'no_app_online_track.dart';
import 'no_track_api.dart';
import 'package:flutter/services.dart';
import 'package:base/log/nine_log.dart';
import 'package:network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoStatisticsTrack with WidgetsBindingObserver implements NetwoMonitor {
  static final _instanceSingle = NoStatisticsTrack._internal();
  factory NoStatisticsTrack() => _instanceSingle;
  static NoStatisticsTrack get instance => NoStatisticsTrack();
  NoStatisticsTrack._internal() : super();
  late String _appCode;
  late String _domain;
  late String _deviceId;
  static const String _keyFirstStartupSent = 'stats.first.startup.sent';
  bool didUploadLaunch = false;
  Timer? timer;
  int tryUploadTime = 1;
  late NoAppOnlineTrack onLineTrack;
  bool isUploading = false;

  Future<void> init() async {
    _appCode = appChannel.mineStatistics;
    _deviceId = "$_appCode${UuidService.currentDeviceID}";
    final config = MgConfigService.instance.getConfigModelByPKey(
      ConfigKey.mginstallsetting,
    );
    String statisticUrl = config?.value1 ?? "";
    _domain = statisticUrl;
    if (statisticUrl.isEmpty) {
      NoTrackApi.upLoadTrackFail(errMessage: "自研启动配置为空");
      return;
    }
    uploadLaunch();
    onLineTrack = NoAppOnlineTrack(
      appCode: _appCode,
      deviceId: _deviceId,
      domain: _domain,
    );
    await onLineTrack.init();
    NetworkListener().addListener(this);
    WidgetsBinding.instance.addObserver(this);
  }

  void creatTimer(int time) {
    timer = Timer.periodic(Duration(seconds: time * tryUploadTime), (time) {
      if (!didUploadLaunch) {
        uploadLaunch();
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  Future<void> uploadLaunch() async {
    if (isUploading) {
      return;
    }
    if (_domain.isEmpty) {
      NoTrackApi.upLoadTrackFail(errMessage: "没有获取到自研埋点域名");
      return;
    }
    isUploading = true;
    bool isFirst = await isFirstLuanch();
    String channelCode = await readChannelCode();
    stopTimer();
    String errString = await NoTrackApi.uploadLaunch(
      isFirst: isFirst,
      appCode: _appCode,
      channelCode: channelCode,
      deviceId: _deviceId,
      domain: _domain,
    );
    isUploading = false;
    if (errString.isEmpty) {
      NoTrackApi.upLoadTrackSuccess();
      didUploadLaunch = true;
      tryUploadTime = 1;
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setBool(_keyFirstStartupSent, true);
    } else {
      NoTrackApi.upLoadTrackFail(errMessage: "测试失败");
      if (timer == null) {
        tryUploadTime += 1;
        creatTimer(3);
      }
    }
  }

  Future<bool> isFirstLuanch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasFirstStartup = prefs.getBool(_keyFirstStartupSent) ?? false;
    return !hasFirstStartup;
  }

  Future<String> readChannelCode() async {
    if (appChannel.mineTrackChannelCode.isNotEmpty) {
      return appChannel.mineTrackChannelCode;
    }
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null && data.text != null) {
        final text = data.text!.trim();
        if (text.isNotEmpty && text.length <= 50) {
          return text;
        }
      }
    } catch (e) {
      NLog.d('读取剪贴板失败: $e');
    }
    return '';
  }

  @override
  void networkChange(ConnectivityResult status) {
    if (status != ConnectivityResult.none && !didUploadLaunch) {
      uploadLaunch();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      onLineTrack.stopTimer();
      onLineTrack.uploadOnlineTime();
    } else if (state == AppLifecycleState.resumed) {
      onLineTrack.creatTimer();
    }
  }
}
