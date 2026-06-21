import 'dart:async';

import 'package:base/device/network_listener.dart';
import 'package:base/log/nine_log.dart';
import 'package:base/nine_globalkey.dart';
import 'package:base/utils/app_channel.dart';
import 'package:base/utils/channel_config.dart';
import 'package:base/utils/nine_env.dart';
import 'package:common/theme/no_splash_theme.dart';
import 'package:common/utils/SharedStorageUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:network/config/uuid_service.dart';
import 'package:oktoast/oktoast.dart';
import 'package:store/store.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    NLog.d('FlutterError: ${details.exception}');
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      NineEnvTool();
      await _setChannel();
      await SharedStorageUtil.init();
      await UuidService.getOrCreateUuid();
      await NetworkListener().init();
      await StoreModule.instance.init();
      runApp(const StoreApp());
    },
    (error, stack) {
      NLog.d('Uncaught: $error\n$stack');
    },
  );
}

Future<void> _setChannel() async {
  final channel = StoreAppChannel(
    channleType: ChannelType.gc,
    categoryType: ChannelCategory.jingxuan,
  );
  await ChannelConfigProvider.load();
  AppChannel.setChannel(channel);
}

class StoreApp extends StatelessWidget {
  const StoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder:
            (context, child) => GetMaterialApp(
              navigatorKey: globalKey,
              debugShowCheckedModeBanner: false,
              translations: StoreTranslations(),
              locale: const Locale('zh', 'CN'),
              fallbackLocale: const Locale('zh', 'CN'),
              theme: applyNoSplashTheme(
                ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.light,
                  scaffoldBackgroundColor: StoreColors.scaffoldBackground,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: StoreColors.tabSelected,
                    brightness: Brightness.light,
                  ),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    foregroundColor: StoreColors.primaryText,
                    elevation: 0,
                    centerTitle: true,
                  ),
                ),
              ),
              builder: EasyLoading.init(),
              home: const StoreAppRoot(),
            ),
      ),
    );
  }
}
