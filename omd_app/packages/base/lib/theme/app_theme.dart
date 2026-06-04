// ignore_for_file: non_constant_identifier_names

import 'package:base/theme/color/colors_theme_new.dart';
import 'package:base/module/base_asset.dart';
import 'package:base/utils/app_channel.dart';
export 'package:base/theme/color/colors_theme_new.dart';

BaseAppColorTheme appColor = NineTheme.instance.appColorTheme;
BaseAsset appAssets = NineTheme.instance.appAsset;
BaseAppChannel get appChannel => AppChannel.getChannel();

class NineTheme {
  static final _instanceSingle = NineTheme._internal();
  factory NineTheme() => _instanceSingle;
  static NineTheme get instance => NineTheme();
  NineTheme._internal() : super();
  late BaseAppColorTheme appColorTheme;
  late BaseAsset appAsset;
  void init({
    required BaseAppColorTheme mNormalColorTheme,
    required BaseAsset mAppAsset,
  }) {
    appColorTheme = mNormalColorTheme;
    appAsset = mAppAsset;
  }
}
