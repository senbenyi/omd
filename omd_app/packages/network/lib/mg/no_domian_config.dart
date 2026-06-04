import 'package:base/device/native_domain_service.dart';
import 'package:base/domain/nine_shared_preferences.dart';
import 'package:base/log/nine_log.dart';
import 'package:base/theme/app_theme.dart';
import 'package:base/utils/nine_env.dart';
import 'package:base/utils/string_util.dart';
import 'package:network/base/base_domain_config.dart';
import 'package:network/http/nine_domian_tool.dart';

enum NetworkLineType {
  guanwang("1"),
  kimi("2");

  final String des;
  const NetworkLineType(this.des);
}

class NODomianConfig extends BaseDomainConfig {
  static final _instanceSingle = NODomianConfig._internal();
  factory NODomianConfig() => _instanceSingle;
  static NODomianConfig get instance => NODomianConfig();
  NODomianConfig._internal() : super();

  NetworkLineType netType = NetworkLineType.guanwang;
  String _currentBaseUrl = "";

  @override
  String get currentDomianKey => "comic_domain";

  @override
  String get serverDomainListKey => "comic_server_domainlist";

  @override
  List<String> get amazonDomains {
    return appChannel.amazonDomains;
  }

  @override
  List<String> get defaultDomains {
    if (nineEnv == EnvType.prod) {
      return appChannel.defaultDomains;
    } else {
      return [];
    }
  }

  @override
  Future<List<String>> requestServersDomains() async {
    if (nineEnv != EnvType.prod) {
      return [];
    }
    List<String> domains = defaultDomains + amazonDomains;
    List<String> serverDomains = [];
    for (var element in domains) {
      serverDomains = await NineDomianTool.requestDomainList(element);
      if (serverDomains.isNotEmpty) {
        baseUrls = serverDomains;
        NLog.d("请求到的域名列表：$serverDomains");
        break;
      }
    }
    return serverDomains;
  }

  Future<String> getKiwiDomain() async {
    final channel = appChannel;

    final kiwiRoot = await NativeDomainService.initKiwi(
      kiwiAppKey: channel.kiwiAppKey,
      kiwiRs: channel.kiwiRs,
    );
    NLog.d("kiki域名---$kiwiRoot");
    if (channel.useKikiLocalRoot && StringUtil.isNotEmpty(kiwiRoot)) {
      return kiwiRoot ?? "";
    }
    return "";
  }

  Future<void> initBaseUrl() async {
    if (nineEnv == EnvType.dev) {
      return;
    }
    String domain = "";
    if (appChannel.useKikiLocalRoot) {
      domain = await getKiwiDomain();
    }
    if (domain.isNotEmpty) {
      setBaseUrl(domain);
      netType = NetworkLineType.kimi;
    } else {
      String url = await NineSharedPreferences.getString(currentDomianKey);
      if (url.isNotEmpty) {
        setBaseUrl(url);
      } else {
        setBaseUrl(defaultDomains.first);
      }
      netType = NetworkLineType.guanwang;
    }
  }

  Future<void> requestServerUrls() async {
    List<String> serverUrls = await requestServersDomains();
    for (var element in serverUrls) {
      bool success = await NineDomianTool.check(domain: element);
      if (success) {
        setBaseUrl(element);
        break;
      }
    }
    NineSharedPreferences.saveString(currentDomianKey, currentBaseUrl);
  }

  @override
  Future<String> checkNewDomian() async {
    if (nineEnv != EnvType.prod) {
      return appChannel.devDomain;
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
    if (nineEnv == EnvType.dev) {
      return appChannel.devDomain;
    }
    return _currentBaseUrl;
  }

  @override
  void setBaseUrl(String domain) async {
    _currentBaseUrl = domain;
  }
}
