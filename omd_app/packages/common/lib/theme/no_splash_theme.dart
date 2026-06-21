import 'package:flutter/material.dart';

/// 全局关闭 Material 点击水波纹 / 高亮效果。
ThemeData applyNoSplashTheme(ThemeData base) {
  const transparentOverlay = WidgetStatePropertyAll<Color?>(Colors.transparent);

  return base.copyWith(
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    hoverColor: Colors.transparent,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(overlayColor: transparentOverlay),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(overlayColor: transparentOverlay),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(overlayColor: transparentOverlay),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(overlayColor: transparentOverlay),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(overlayColor: transparentOverlay),
    ),
  );
}
