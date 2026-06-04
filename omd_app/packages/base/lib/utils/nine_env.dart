enum EnvType { dev, prod }

// 默认走 dev：本地调试不依赖线上域名列表
EnvType nineEnv = EnvType.prod;
EnvType tiyuEnv = EnvType.prod;
EnvType offerEnv = EnvType.dev;

class NineEnvTool {
  static String? xInstallKey;
  NineEnvTool() {
    //xInstallKey
    String key = const String.fromEnvironment('INSTALL_KEY', defaultValue: '');
    if (key.isNotEmpty) {
      xInstallKey = key;
    }
    //环境
    String mEnv = String.fromEnvironment('ENV', defaultValue: '');
    if (mEnv.isNotEmpty) {
      if (mEnv == "prod") {
        nineEnv = EnvType.prod;
      } else {
        nineEnv = EnvType.dev;
      }
    }
  }
}
