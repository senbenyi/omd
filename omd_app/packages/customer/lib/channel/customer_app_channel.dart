import 'package:base/utils/app_channel.dart';
import 'package:base/utils/mg_bottom_tab_type.dart';
import 'package:base/utils/tv_bottom_tab_type.dart';

/// Customer 业务渠道配置。
class CustomerAppChannel extends BaseAppChannel {
  CustomerAppChannel({required super.channleType, required super.categoryType});

  @override
  List<MgBottomTabbarType> get mgTabbarItems => [];

  @override
  List<TvBottomTabbarType> get tvTabbarItems => [];

  @override
  int get tikokIndex => 0;

  @override
  int get firstLaunchIndex => 0;

  @override
  NineThemeMode get themeMode => NineThemeMode.light;

  @override
  String get devDomain => '';

  @override
  String get videoDomain => '';

  @override
  String get imageDomain => '';
}
