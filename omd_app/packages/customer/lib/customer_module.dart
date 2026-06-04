import 'package:base/module/base_module.dart';

/// Customer 业务模块入口。
class CustomerModule implements BaseModule {
  CustomerModule._();
  static final CustomerModule _instance = CustomerModule._();
  factory CustomerModule() => _instance;
  static CustomerModule get instance => _instance;

  Future<void> init() async {}

  @override
  void initAssets() {}

  @override
  void initColorTheme() {}
}
