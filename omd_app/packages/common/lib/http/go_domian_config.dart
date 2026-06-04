import 'package:base/domain/nine_shared_preferences.dart';
import 'package:base/theme/app_theme.dart';
import 'package:network/base/base_domain_config.dart';
import 'package:base/utils/nine_env.dart';
import 'package:network/http/nine_domian_tool.dart';

enum NetworkLineType {
  guanwang("1"),
  kimi("2");

  final String des;
  const NetworkLineType(this.des);
}

class GoDomianConfig extends BaseDomainConfig {
  static final _instanceSingle = GoDomianConfig._internal();
  factory GoDomianConfig() => _instanceSingle;
  static GoDomianConfig get instance => GoDomianConfig();
  GoDomianConfig._internal() : super();

  String _currentBaseUrl = "";

  @override
  String get currentDomianKey => "go_domain";

  @override
  String get serverDomainListKey => "go_server_domainlist";

  @override
  List<String> get amazonDomains => appChannel.amazonDomains;

  @override
  List<String> get defaultDomains {
    if (nineEnv == EnvType.prod) {
      return appChannel.defaultDomains;
    }
    return [];
  }

  Future<void> initBaseUrl() async {
    if (nineEnv == EnvType.dev) {
      setBaseUrl(appChannel.devDomain);
      return;
    }
    final saved = await NineSharedPreferences.getString(currentDomianKey);
    if (saved.isNotEmpty) {
      setBaseUrl(saved);
      return;
    }
    if (defaultDomains.isNotEmpty) {
      setBaseUrl(defaultDomains.first);
    }
  }

  @override
  Future<List<String>> requestServersDomains() async {
    return [];
  }

  @override
  Future<String> checkNewDomian() async {
    if (nineEnv != EnvType.prod) {
      return baseUrls.first;
    }

    if (baseUrls.isEmpty) {
      return "";
    }
    String newBaseUrl = "";
    for (var url in baseUrls) {
      if (url == currentBaseUrl) {
        continue;
      }
      bool success = await NineDomianTool.check(domain: url);
      if (success) {
        newBaseUrl = url;
        setBaseUrl(newBaseUrl);
        NineSharedPreferences.saveString(currentDomianKey, currentBaseUrl);
        break;
      }
    }
    return newBaseUrl;
  }

  @override
  String get currentBaseUrl {
    if (offerEnv == EnvType.dev) {
      return appChannel.devDomain;
    }
    return _currentBaseUrl;
  }

  @override
  void setBaseUrl(String domain) async {
    _currentBaseUrl = domain;
  }
}
