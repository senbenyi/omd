import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:base/log/nine_log.dart';

abstract class NetwoMonitor {
  void networkChange(ConnectivityResult status);
}

class NetworkListener {
  static final NetworkListener _instance = NetworkListener._internal();
  factory NetworkListener() => _instance;
  final Connectivity _connectivity = Connectivity();
  List<NetwoMonitor> listeners = [];
  ConnectivityResult _currentResultStatus = ConnectivityResult.none;

  NetworkListener._internal() {
    _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _currentResultStatus = results.first;
        NLog.d("[NetworkListener] 网络状态变化: $results");
        notify();
      },
      onError: (error) {
        NLog.e("[NetworkListener] 网络监听错误: $error");
      },
    );
  }

  void addListener(NetwoMonitor element) {
    if (!listeners.contains(element)) {
      listeners.add(element);
    }
    notify();
  }

  void removeListener(NetwoMonitor element) {
    if (listeners.contains(element)) {
      listeners.remove(element);
    }
  }

  void notify() {
    // 创建列表副本以避免并发修改错误
    final List<NetwoMonitor> listenersCopy = List.from(listeners);
    for (var monitor in listenersCopy) {
      try {
        monitor.networkChange(_currentResultStatus);
      } catch (e, stack) {
        NLog.e("[NetworkListener] 通知监听器时出错: $e", stack);
      }
    }
  }

  /// 检查是否有网络连接
  bool get hasConnection {
    return _currentResultStatus != ConnectivityResult.none;
  }

  /// 初始化并开始监听网络变化
  Future<void> init() async {
    try {
      // 获取初始网络状态
      List<ConnectivityResult> resultsArray =
          await _connectivity.checkConnectivity();
      if (resultsArray.isNotEmpty) {
        _currentResultStatus = resultsArray.first;
      }
      NLog.d("网络状态: $_currentResultStatus");
    } catch (e) {
      NLog.e("[NetworkListener] 初始化失败: $e");
    }
  }
}
