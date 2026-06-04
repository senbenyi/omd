import 'dart:math';

import 'package:base/utils/mg_bottom_tab_type.dart';
import 'package:base/utils/tv_bottom_tab_type.dart';

import 'channel_config.dart';

enum ChannelType {
  // 黑色
  jingxuan("精选"),
  kuaibo("快播"),
  fuli("福利"),
  juzi("桔子TV"),
  adultDy("成人抖音"),
  xiangjiang("香蕉"),
  tianyashequ("天涯"),
  //白色
  gc("工厂"),
  shiping("视频"),
  manhua("漫画"),
  madou("麻豆"),
  huli("狐狸"),
  xingba("杏吧"),
  tv("TV");

  final String value;
  const ChannelType(this.value);
}

enum ChannelCategory {
  // 黑色
  jingxuan("精选系列"),
  manhua("漫画系列"),
  adultDy("成人抖音系列"),
  tianya("漫画系列"),
  tv("TV系列");

  final String value;
  const ChannelCategory(this.value);
}

enum NineThemeMode { light, dark }

class AppChannel {
  static late BaseAppChannel _currentChannel;
  static void setChannel(BaseAppChannel channel) {
    _currentChannel = channel;
  }

  static BaseAppChannel getChannel() {
    return _currentChannel;
  }
}

abstract class BaseAppChannel {
  final ChannelType channleType;
  final ChannelCategory categoryType;

  BaseAppChannel({required this.channleType, required this.categoryType});

  String get kiwiAppKey {
    {
      String key = """JtW3SnQxVVhpu3D4z0N2hL0Pzq+RL/8ygkXbFVzzdKujgFeUYKI+gepSoi
    DhkYdNWGdlpO+3PaMoSBpvA2s8UY02VKKoEF15SKiNWCjlT50jvSCxusjIgxPiLHn+Bp4Uq3DB
    6nPDkaLyFGuZUn3lHpFDmODSUsCmvByNTDv6BlLq8nMxVX/BGefSm9J02S2tjqDGKaziQPlGT1
    J4LsVEGPZ5d4XdjLAqHGvbZz6wzbyhI9ItJe38MvMaMjodF6HNbAiEvdWloJXat5itJ5sWNYeIf
    80EiO1a5sPEVnR6PvM00eq/SEy7nqTnl7xXbnKkXQpCdcFFOVoBflrNGJni3NeAubC2badxXT/FL
    2UiVLWiLp1lo1zoFNWrweOs6olngDT0J2jB2O3EwzSZb78+3uOkaOAjuo3ClgUIJI3sM8m4F3QYp
    NKvKlk1boYaUuliZfc0UehALaYdzoUpwoIzuBSP7cHAcMTd0SpFTJMh9h9q3QF4hFa6UGxjcSquT
    nObmLwgvTM/+If86UanBZu9o+dGswB+h2jo2gGxCYW5/nKQ5b7d8qCvz4Isrxa9EnX3vNf2OxKj
    URab9n7yOFeadhk7ZNN/1QvedonZspRNRKaoX7+N70QhwoObl4UKA0aEyCG8gIItNhgOvhLtjI
    CY3+Jl6vsT4B47ruXs9BElpjfri3k12K4yLArgkHNq3OufiPrpiFfiymeXlqQc9Pa3Zw==
""";
      return key.replaceAll('\n', '').replaceAll(' ', '');
    }
  }

  String get devDomain => "https://mgapi.md201.cc";
  bool get showWoldCup =>
      ChannelConfigProvider.currentEntry?.showWorldCup ?? true;

  String get xInstallKey {
    return ChannelConfigProvider.currentEntry?.installKey ?? "";
  }

  String get kiwiRs => ChannelConfigProvider.currentEntry?.kiwiRs ?? "";
  String get appName {
    String name = ChannelConfigProvider.currentEntry?.appName ?? '';
    return name;
  }

  String get mineStatistics =>
      ChannelConfigProvider.currentEntry?.mineTrackKey ?? "";
  String get mineTrackChannelCode =>
      ChannelConfigProvider.currentEntry?.mineTrackChannelCode ?? "";

  List<String> get amazonDomains =>
      ChannelConfigProvider.currentEntry?.aws ?? [];
  bool get isSandBox {
    return ChannelConfigProvider.currentEntry?.isSandbox == 1;
  }

  List<String> get defaultDomains {
    List array = ChannelConfigProvider.currentEntry?.domains ?? [];
    return array.map((e) {
      return "https://${generateRandomSubdomain()}.$e";
    }).toList();
  }

  String generateRandomSubdomain({int length = 8}) {
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  bool get useKikiLocalRoot => true;
  // ---------- 仍由各渠道实现的差异化 ----------
  List<MgBottomTabbarType> get mgTabbarItems;
  List<TvBottomTabbarType> get tvTabbarItems => [];
  int get tikokIndex;
  int get firstLaunchIndex;
  NineThemeMode get themeMode;
  String get videoDomain;
  String get imageDomain;

  /// 图片占位水印域名。TV 等在子类中会覆盖（读 TVSetting）。
  /// MG 等系列若未覆盖，则用渠道包 [ChannelConfigProvider] 的域名或应用名兜底，避免默认为空字符串导致 [NinePlaceholder.domainText] 不显示。
  String get placeHolderDomain {
    final entry = ChannelConfigProvider.currentEntry;
    final domains = entry?.domains ?? [];
    if (domains.isNotEmpty) return domains.first;
    final name = entry?.appName;
    if (name != null && name.isNotEmpty) return name;
    return "";
  }

  bool get isDark {
    return themeMode == NineThemeMode.dark;
  }

  /// 图片占位是否使用域名水印（[PlaceholderType.domainText] / [TvPlaceholder]）。
  ///
  /// 默认仅 TV [ChannelType.tv]；天涯等宿主在对应 [BaseAppChannel] 子类中覆盖。
  bool get placeholderUsesDomainWatermark => channleType == ChannelType.tv;
}
