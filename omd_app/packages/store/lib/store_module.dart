import 'package:base/module/base_module.dart';
import 'package:common/http/go_http.dart';
import 'package:common/http/go_http_config.dart';
import 'package:get/get.dart';
import 'package:store/common/user/go_user_controller.dart';

/// Store 业务模块入口。
class StoreModule implements BaseModule {
  StoreModule._();
  static final StoreModule _instance = StoreModule._();
  factory StoreModule() => _instance;
  static StoreModule get instance => _instance;

  Future<void> init() async {
    await GoHttp.instance.registerHttpServer(GoHttpConfig.instance);
    if (!Get.isRegistered<GoUserController>()) {
      Get.put(GoUserController(), permanent: true);
    }
  }

  @override
  void initAssets() {}

  @override
  void initColorTheme() {}
}
