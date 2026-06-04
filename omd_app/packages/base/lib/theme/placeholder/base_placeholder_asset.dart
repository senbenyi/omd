import 'package:flutter/material.dart';

//空值占位图
enum EmptyDataType { banner, horizontal, vertical, longBanner, square, list }

/// 图片占位符类型
enum PlaceholderType {
  none,
  banner,
  horizontal,
  vertical,
  longBanner,
  square,
  horizontalCard,
  discover,
  domainText
}

abstract class BasePlaceholderAsset {
  AssetImage normalAssetPlaceHolder(PlaceholderType type); //普通页面
  AssetImage emptyDataAsset(EmptyDataType type); //普通页面
}
