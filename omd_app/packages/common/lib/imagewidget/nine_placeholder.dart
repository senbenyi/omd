import 'package:base/theme/app_theme.dart';
import 'package:base/theme/placeholder/base_placeholder_asset.dart';
import 'package:common/imagewidget/auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NinePlaceholder {
  /// 在父级只给宽度、纵向无上限时仍可得到有限高度；在有界矩形内继续铺满。
  static double resolveLayoutMaxWidth(BoxConstraints constraints) {
    if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
      return constraints.maxWidth;
    }
    if (constraints.minWidth.isFinite && constraints.minWidth > 0) {
      return constraints.minWidth;
    }
    return 300;
  }

  static Widget getPLaceHolder(
    PlaceholderType? type, {
    int domiantextLine = 1,
    double? domianFontsize,
  }) {
    if (type == null) {
      return SizedBox.shrink();
    }
    if (type == PlaceholderType.none) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final double w = resolveLayoutMaxWidth(constraints);
          if (!constraints.hasBoundedHeight) {
            return Container(width: w, height: w, color: appColor.placeholderBg);
          }
          final double h = constraints.maxHeight;
          return SizedBox(
            width: w,
            height: h,
            child: DecoratedBox(
              decoration: BoxDecoration(color: appColor.placeholderBg),
              child: const SizedBox.expand(),
            ),
          );
        },
      );
    }
    if (type == PlaceholderType.domainText) {
      return TvPlaceholder(maxlIne: domiantextLine, fontSize: domianFontsize);
    }

    final String path = normalAssetPlaceHolder(type);
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = resolveLayoutMaxWidth(constraints);
        if (!constraints.hasBoundedHeight) {
          return SizedBox(
            width: w,
            child: Image.asset(path, width: w, fit: BoxFit.fitWidth),
          );
        }

        final double h = constraints.maxHeight;
        return SizedBox(
          width: w,
          height: h,
          child: Image.asset(path, fit: BoxFit.cover, width: w, height: h),
        );
      },
    );
  }

  static String normalAssetPlaceHolder(PlaceholderType type) {
    String path = "";
    switch (type) {
      case PlaceholderType.banner:
      case PlaceholderType.horizontal:
        path = appAssets.placeholderDefault;
      case PlaceholderType.vertical:
        path = appAssets.placeholderDefault2;
      case PlaceholderType.longBanner:
        path = appAssets.placeholderLongBanner;
      case PlaceholderType.square:
        path = appAssets.placeholderSqare;
      case PlaceholderType.horizontalCard:
        path = appAssets.placeholderVlDefault;
      case PlaceholderType.discover:
        path = appAssets.placeholderDiscover;
      case PlaceholderType.domainText:
      case PlaceholderType.none:
    }
    return path;
  }
}

class TvPlaceholder extends StatelessWidget {
  final double? fontSize;
  final int maxlIne;

  const TvPlaceholder({super.key, this.fontSize, this.maxlIne = 1});

  @override
  Widget build(BuildContext context) {
    final resolvedFontSize = fontSize ?? 40.sp;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = NinePlaceholder.resolveLayoutMaxWidth(constraints);

        Widget textPane() => ConstrainedBox(
          constraints: BoxConstraints(maxWidth: w * 0.72),
          child: AutoSizeText(
            appChannel.placeHolderDomain,
            maxLines: maxlIne,
            minFontSize: 8,
            maxFontSize: double.infinity,
            stepGranularity: 0.1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'YouSheBiaoTiHei',
              fontSize: resolvedFontSize,
              color: Colors.white.withValues(alpha: 0.08),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        );

        if (!constraints.hasBoundedHeight) {
          return ColoredBox(
            color: appColor.placeholderBg,
            child: SizedBox(
              width: w,
              child: Center(child: textPane()),
            ),
          );
        }

        final double h = constraints.maxHeight;
        return Container(
          width: w,
          height: h,
          alignment: Alignment.center,
          color: appColor.placeholderBg,
          child: textPane(),
        );
      },
    );
  }
}
