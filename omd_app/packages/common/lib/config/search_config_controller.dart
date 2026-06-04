import 'package:common/config/mg_config_service.dart';
import 'package:get/get.dart';

class SearchConfigController extends GetxController {
  bool canSearch = true;
  bool needLogin = false;
  var searchPlaceHolder = "搜索您想看的视频～".obs;

  Future<void> getSearchConfig() async {
    ConfigKey key = ConfigKey.searchsetting;
    ConfigModel? configModel = MgConfigService.instance.getConfigModelByPKey(key);
    ConfigModel? config = configModel;
    String value1 = config?.value1 ?? "";
    String value2 = config?.value2 ?? "";
    // 1. 通过配置判断是否可以搜索
    canSearch = value1 == '1';
    // 2. 点击搜索是否需要登录：value2=0 需要登录，value2=1 允许未登录
    needLogin = value2 != '1';
    getSearchTextArr();
  }

  // 获取输入框文案
  void getSearchTextArr() {
    ConfigModel? configModel = MgConfigService.instance.getConfigModelByPKey(
      ConfigKey.SEACHDomain,
    );
    String strs = configModel?.value1 ?? '';
    List<String> list = strs.split(',');
    if (list.isNotEmpty) {
      searchPlaceHolder.value = list.first;
    }
  }
}
