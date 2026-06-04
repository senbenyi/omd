import 'dart:typed_data';
import 'package:base/theme/app_theme.dart';
import 'package:base/utils/app_channel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/imagewidget/nine_image_background.dart';
import 'package:common/imagewidget/nine_img_tool.dart';
import 'package:common/imagewidget/nine_placeholder.dart';
import 'package:common/imagewidget/widget/nine_adgif_image.dart';
import 'package:common/imagewidget/widget/nine_op_image.dart';
import 'package:common/imagewidget/widget/nine_video_op_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:base/theme/placeholder/base_placeholder_asset.dart';
import 'package:flutter/material.dart';

import 'widget/nine_op_image_tv_text_shimmer.dart';

export '../imagewidget/nine_image_background.dart';
export '../imagewidget/nine_img_tool.dart';

class NineImageBuilder {
  /// 静态图 / OP 图占位底色，未传时使用 [NineImageBackground.resolve]。
  static Color resolveBackgroundColor(Color? backgroundColor) {
    return NineImageBackground.resolve(backgroundColor);
  }

  /// GIF 图占位底色，未传时使用 [NineImageBackground.resolveForGif]。
  static Color resolveGifBackgroundColor(Color? backgroundColor) {
    return NineImageBackground.resolveForGif(backgroundColor);
  }

  static Widget buildGifImage({
    required String url,
    bool showPlaceholder = true,
    ImageType imageType = ImageType.static,
    String title = "",
    double? width,
    double? height,
    BoxFit? fit,
    Widget? errorWidget,
    Alignment? alignment,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
    double? radius,
    bool autoSpeed = true,
    Color? backgroundColor,
  }) {
    return NineAdgifImage(
      url: url,
      title: title,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      borderRadius: borderRadius,
      errorWidget: errorWidget,
      onTap: onTap,
      radius: radius ?? 0,
      backgroundColor: backgroundColor,
    );
  }

  /// CDN 解密静态图封装为 [NineopImage]。
  ///
  /// [title] 会传入下载/解压链路（[NineImageProvider.requestImageData]），可用于日志或与业务绑定；默认可不传。
  static Widget buildOpImage({
    required String url,
    String title = "",
    double? width,
    double? height,
    BoxFit? fit,
    Widget? errorWidget,
    Alignment? alignment,
    VoidCallback? onTap,
    double? radius,
    BorderRadius? borderRadius,
    ValueChanged<Uint8List>? onImageBytesReady,
    int? cacheWidth,
    int? cacheHeight,
    PlaceholderType placeholderType = PlaceholderType.domainText,
    Widget? placeholder,
    Function(Uint8List bytes)? onImageBytesLoaded,
    Color? backgroundColor,
  }) {
    return NineopImage(
      url: url,
      title: title,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      alignment: alignment,
      onTap: onTap,
      radius: radius,
      borderRadius: borderRadius,
      placeholder:
          placeholder ?? NinePlaceholder.getPLaceHolder(placeholderType),
      onImageBytesReady: onImageBytesReady,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      backgroundColor: backgroundColor,
    );
  }

  static Widget videoOpImage({
    required String imageUrl,
    required String trailUrl,
    String title = "",
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Alignment? alignment,
    VoidCallback? onTap,
    double? radius,
    int? cacheWidth,
    int? cacheHeight,
    Color? backgroundColor,
  }) {
    return NineVideoOpImage(
      imageUrl: imageUrl,
      trailUrl: trailUrl,
      title: title,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      alignment: alignment,
      placeholder: placeholder,
      radius: radius ?? 0,
      onTap: onTap,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      backgroundColor: backgroundColor,
    );
  }

  static Widget buildCachedImage({
    required String url,
    double? width,
    double? height,
    BoxFit? fit,
    Alignment? alignment,
    VoidCallback? onTap,
    double? radius,
    BorderRadius? borderRadius,
    int? cacheWidth,
    int? cacheHeight,
    required Widget placeholder,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(radius ?? 0),
        child: ColoredBox(
          color: resolveBackgroundColor(backgroundColor),
          child: CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          memCacheWidth: cacheWidth,
          memCacheHeight: cacheHeight,
          placeholder: (context, url) {
            if (appChannel.channleType == ChannelType.tv) {
              return NineOpImageTvTextShimmer(
                label: appChannel.placeHolderDomain,
              );
            }
            return placeholder;
          },
          errorWidget: (context, url, error) {
            return placeholder;
          },
        ),
        ),
      ),
    );
  }
}
