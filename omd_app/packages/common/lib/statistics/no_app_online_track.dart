import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'no_track_api.dart';

class NoAppOnlineTrack {
  final String _appCode;
  final String _deviceId;
  final String _domain;
  NoAppOnlineTrack({
    required String appCode,
    required String deviceId,
    required String domain,
  }) : _appCode = appCode,
       _deviceId = deviceId,
       _domain = domain;
  late SharedPreferences prefs;
  late String _dateKey;
  int _totalSeconds = 0;
  int upLoadTime = 0;
  Timer? timer;
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    _dateKey = getTodayString();
    _totalSeconds = prefs.getInt(_dateKey) ?? 0;
    if (_totalSeconds > 0) {
      uploadOnlineTime();
    }
    creatTimer();
  }

  void creatTimer() {
    if (timer != null) {
      timer?.cancel();
      timer = null;
    }
    int seconds = 5;
    timer = Timer.periodic(Duration(seconds: seconds), (time) {
      _totalSeconds += seconds;
      // NoTrackApi.log("当前时长：$_totalSeconds");
      prefs.setInt(_dateKey, _totalSeconds);
      if (_dateKey != getTodayString()) {
        _dateKey = getTodayString();
        _totalSeconds = 0;
        prefs.setInt(_dateKey, _totalSeconds);
      }
      if (_totalSeconds % 120 == 0 && _totalSeconds > 120) {
        uploadOnlineTime();
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  Future<void> uploadOnlineTime() async {
    if (_domain.isEmpty || _totalSeconds == 0) {
      return;
    }
    if (_dateKey != getTodayString()) {
      return;
    }
    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (now - upLoadTime < 5) {
      return;
    }
    upLoadTime = now;
    await NoTrackApi.uploadOnlineTime(
      appCode: _appCode,
      totalSeconds: _totalSeconds.toString(),
      deviceId: _deviceId,
      domain: _domain,
    );
  }

  String getTodayString() {
    final beijingNow = DateTime.now().toUtc().add(const Duration(hours: 8));
    String year = beijingNow.year.toString().padLeft(4, '0');
    String month = beijingNow.month.toString().padLeft(2, '0');
    String day = beijingNow.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }
}
