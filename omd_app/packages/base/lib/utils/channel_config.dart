import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:base/log/nine_log.dart';
import 'package:base/utils/nine_env.dart';

/// 渠道配置提供者：仅从 assets/channel_config.json 读取，当前条由打包环境变量 INSTALL_KEY 匹配
class ChannelConfigProvider {
  static ChannelConfigEntry? currentEntry;
  static Future<void> load({String path = 'assets/channel_config.json'}) async {
    try {
      final str = await rootBundle.loadString(path);
      final list = jsonDecode(str) as List<dynamic>?;
      List<ChannelConfigEntry> allEntries =
          (list ?? [])
              .map(
                (e) => ChannelConfigEntry.fromJson(e as Map<String, dynamic>?),
              )
              .whereType<ChannelConfigEntry>()
              .toList();
      if (allEntries.isEmpty) {
        NLog.e('$path is empty or invalid');
        return;
      }

      final xInstallKey = NineEnvTool.xInstallKey;
      currentEntry = allEntries.firstWhere(
        (e) =>
            xInstallKey != null && xInstallKey.isNotEmpty
                ? e.installKey == xInstallKey
                : false,
        orElse: () => allEntries.first,
      );
    } catch (e, st) {
      NLog.e('读取渠道配置失败($path): $e');
      NLog.e(st);
    }
  }
}

class ChannelConfigEntry {
  ChannelConfigEntry({
    required this.installKey,
    required this.kiwiRs,
    required this.mineTrackKey,
    required this.domains,
    required this.aws,
    required this.ios,
    required this.android,
    required this.appName,
    required this.mineTrackChannelCode,
    required this.isSandbox,
    required this.showWorldCup,
  });

  final String installKey;
  final String kiwiRs;
  final String mineTrackKey;
  final List<String> domains;
  final List<String> aws;
  final String ios;
  final String android;
  final String appName;
  final String mineTrackChannelCode;
  final int isSandbox;
  final bool showWorldCup;

  static ChannelConfigEntry? fromJson(Map<String, dynamic>? map) {
    if (map == null) return null;
    String domain = map['domains'] ?? "";
    String awsStr = map['aws'] ?? "";
    List<String> domainsList =
        domain
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    List<String> aws =
        awsStr
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    domain.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return ChannelConfigEntry(
      installKey: (map['installKey'] as String?) ?? '',
      kiwiRs: (map['kiwiRs'] as String?) ?? '',
      mineTrackKey: (map['mineTrackKey'] as String?) ?? '',
      domains: domainsList,
      aws: aws,
      ios: (map['ios'] as String?) ?? '',
      android: (map['android'] as String?) ?? '',
      appName: (map['appName'] as String?) ?? '',
      mineTrackChannelCode: (map['mineTrackChannelCode'] as String?) ?? '',
      isSandbox: map["isSandbox"] ?? 0,
      showWorldCup: map['showWorldCup'] ?? true,
    );
  }
}
