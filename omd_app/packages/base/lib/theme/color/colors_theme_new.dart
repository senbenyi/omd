import 'package:flutter/material.dart';

abstract class BaseAppColorTheme {
  Color get primary; //主题色
  Color get onPrimary; //主题色背景上的文字颜色

  Color get scaffoldBackground; //页面背景色
  Color get appBarBackground; //arrBar页面背景色
  Color get surface; //页面颜色
  Color get placeholderBg; // 站位图背景颜色
  Color get onSurfaceIcon; //页面上Icon的颜色
  Color get onSurfaceText; //页面上Text的颜色
  Color get bigTitle; //大标题

  Color get cardTitle; //卡片标题
  Color get cardSecondary; //卡片次级文字
  Color get cardThree; //卡片三级文字颜色

  Color get emptyPageText; //空页面占位文字颜色
  Color get easyRefreshText; // 下拉刷新和上拉加载 字体颜色
  Color get easyRefreshIcon; // 下拉刷新和上拉加载 图标颜色

  Color get divider; //分割线
  Color get placeHolderCard; //分割线

  Color get tabSelectTextColor; // 漫画item类型标签
  Color get tabSelectBgColor; // 漫画item类型标签
  Color get tabBarText;
  Color get tabBarBg;
  Color get tabIndicatorColor;
  Color get boottomSheetBackground;

  // 评论底部弹窗相关颜色
  Color get onSurface; // 主要文字颜色（用于评论弹窗标题、内容等）
  Color get onSurfaceVariant; // 次要文字颜色（用于评论弹窗提示文字、用户名等）
  Color get surfaceContainerHighest; // 输入框背景色（用于评论弹窗输入框背景）
  Color get commentBackgorund; // 主要文字颜色（用于评论弹窗标题、内容等）
  List<Color> get pageBackGroubGradient; //顶部背景渐变色
  Color get placeholderText; //暂未图文字颜色
}
