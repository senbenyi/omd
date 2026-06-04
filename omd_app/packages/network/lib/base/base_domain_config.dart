abstract class BaseDomainConfig {
  List<String> baseUrls = []; // 可用的基础域名列表
  List<String> get amazonDomains;
  List<String> get defaultDomains;
  String get currentDomianKey;
  String get serverDomainListKey;
  Future<List<String>> requestServersDomains();
  String get currentBaseUrl;
  void setBaseUrl(String domain);
  Future<String> checkNewDomian();
}
