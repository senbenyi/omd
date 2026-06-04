import 'dart:async';
import 'dart:typed_data';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:base/log/nine_log.dart';

enum AudioStatus { none, loading, playing, pause, finish, stop }

abstract class AudioListener {
  void progressChange(Duration position, Duration totalDuration);
  void statusChange(AudioStatus status);
  void error(String message);
}

class SoundPlayer {
  static final SoundPlayer _instance = SoundPlayer._internal();
  factory SoundPlayer() => _instance;
  SoundPlayer._internal();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isInited = false;
  AudioListener? currentListener;

  void addLister(AudioListener listener) {
    currentListener = listener;
  }

  void removeLister() {
    currentListener = null;
  }

  // 当前缓存的进度/时长
  Duration _currentPosition = Duration.zero;
  Duration _currentDuration = Duration.zero;

  Future<void> init() async {
    if (_isInited) return;
    await _player.openPlayer();
    // 后台播放必须启用 audio_session
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration.music(), // 适用于音乐播放
    );
    // 设置进度回调间隔
    _player.setSubscriptionDuration(const Duration(milliseconds: 200));
    _player.onProgress?.listen((event) {
      _currentPosition = event.position;
      _currentDuration = event.duration;
      if (_currentDuration.inMilliseconds > 0) {
        currentListener?.progressChange(_currentPosition, _currentDuration);
      }
      // NLog.d("$event 进度：$_currentPosition 总时长：$_currentDuration");
    });
    _isInited = true;
  }

  Future<void> playBytes(
    Uint8List bytes, {
    Codec codec = Codec.pcm16WAV,
    double speed = 1.0,
  }) async {
    try {
      await init();
      await _player.startPlayer(
        fromDataBuffer: bytes,
        codec: codec,
        whenFinished: () {
          _currentPosition = _currentDuration;

          currentListener?.progressChange(_currentDuration, _currentDuration);
          currentListener?.statusChange(AudioStatus.finish);
        },
      );
      await setSpeed(speed);
      currentListener?.statusChange(AudioStatus.playing);
    } catch (e) {
      NLog.e("音频播放器初始化失败");
    }
  }

  Future<void> pause() async {
    await _player.pausePlayer();
    currentListener?.statusChange(AudioStatus.pause);
  }

  Future<void> resume() async {
    await _player.resumePlayer();
    currentListener?.statusChange(AudioStatus.playing);
  }

  Future<void> stop() async {
    await _player.stopPlayer();
    currentListener?.statusChange(AudioStatus.stop);
    _currentPosition = Duration.zero;
    _currentDuration = Duration.zero;
  }

  Future<void> seek(Duration position) async {
    await _player.seekToPlayer(position);
    _currentPosition = position;
    if (_currentDuration.inMilliseconds > 0) {
      currentListener?.progressChange(_currentPosition, _currentDuration);
    }
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  // ---- 正确的“获取”方法：返回缓存的值（即时、无网络） ----
  Future<Duration> getPosition() async {
    return _currentPosition;
  }

  Future<Duration> getDuration() async {
    return _currentDuration;
  }

  Future<void> dispose() async {
    try {
      await stop();
    } catch (_) {}
    await _player.closePlayer();
    _isInited = false;
  }
}
