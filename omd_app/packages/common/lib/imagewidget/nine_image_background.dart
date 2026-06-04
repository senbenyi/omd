import 'package:base/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// [NineImageBuilder] / 图片组件统一的占位底色解析。
class NineImageBackground {
  NineImageBackground._();

  /// 静态图、OP 图默认使用主题占位色 [appColor.placeholderBg]。
  static Color resolve(Color? backgroundColor) {
    return backgroundColor ?? appColor.placeholderBg;
  }

  /// GIF 广告图默认：暗色 `Colors.white12`，亮色 `#F5F5F5`。
  static Color resolveForGif(Color? backgroundColor) {
    if (backgroundColor != null) {
      return backgroundColor;
    }
    return appChannel.isDark ? Colors.white12 : const Color(0xFFF5F5F5);
  }
}
