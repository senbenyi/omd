import 'package:common/refresh/loading/td_loading.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:base/theme/app_theme.dart';
enum LoadingType {
  /// json 文件
  Json,

  /// 菊花状
  activity,
}

class MG51AnimatedLogo extends StatefulWidget {
  final double width;
  final double height;
  final Color? color;
  final String imageName;
  final LoadingType type;

  const MG51AnimatedLogo({
    super.key,
    this.width = 80,
    this.height = 100,
    this.color,
    this.imageName = "",
    this.type = LoadingType.Json,
  });

  @override
  State<MG51AnimatedLogo> createState() => _MG51AnimatedLogoState();
}

class _MG51AnimatedLogoState extends State<MG51AnimatedLogo>
    with TickerProviderStateMixin {
  double totalProgress = 0;

  String defaultDomainLogo = appAssets.refreshLoading;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color color = widget.color ?? (appChannel.isDark ? Colors.white : Colors.black);
    Widget child = SizedBox(
      width: 100,
      height: 100,
      child: Lottie.asset(defaultDomainLogo, backgroundLoading: false),
    );
    if (widget.type == LoadingType.activity) {
      child = TDLoading(
        iconColor: color,
        size: TDLoadingSize.large,
        icon: TDLoadingIcon.activity,
      );
    }
    return Center(child: child);
  }
}
