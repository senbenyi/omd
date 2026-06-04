import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui' show FrameInfo;
import 'package:common/imagewidget/nine_image_background.dart';
import 'package:common/imagewidget/nine_img_tool.dart';
import 'package:flutter/material.dart';
import '../download_center/nine_image_provider.dart';
import 'gif_painter_widget.dart';

class NineAdgifImage extends StatefulWidget {
  const NineAdgifImage({
    super.key,
    required this.url,
    this.title = "",
    this.width,
    this.height,
    this.fit = BoxFit.fill,
    this.errorWidget,
    this.onTap,
    this.borderRadius,
    this.alignment,
    this.frameRate,
    this.fadeDuration = const Duration(milliseconds: 700),
    this.radius = 0,
    this.placeholder,
    this.autoSpeed = true,
    this.imageType = ImageType.static,

    /// 为 null 时使用 [NineImageBackground.resolveForGif]。
    this.backgroundColor,
  });

  final String url;
  final String title;

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Alignment? alignment;
  final BoxFit? fit;
  final VoidCallback? onTap;
  final Widget? errorWidget;
  final int? frameRate;
  final Duration fadeDuration;
  final double radius;
  final Widget? placeholder;
  final bool autoSpeed;
  final ImageType imageType;
  final Color? backgroundColor;

  @override
  State<NineAdgifImage> createState() => _NineAdgifImageState();
}

class _NineAdgifImageState extends State<NineAdgifImage> {
  ui.Codec? _codec; //广告Gif使用
  FrameInfo? _firstFrmame; //广告Gif使用
  double? _realImageHeight;
  int _loadToken = 0;
  bool _initialLoadStarted = false;

  @override
  void initState() {
    super.initState();
    _realImageHeight = widget.height;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialLoadStarted) {
      return;
    }
    _initialLoadStarted = true;
    _loadImage();
  }

  @override
  void dispose() {
    // NLog.d("XXXXXXX${widget.title} NineAdgifImage dispose");
    NineImageProvider.instance.changePriority(widget.url, 0);
    _disposeImageResources();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NineAdgifImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _disposeImageResources();
      setState(() {});
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final int token = ++_loadToken;
    Uint8List? mmData = await NineImageProvider.instance.requestImageData(
      widget.url,
      isAd: true,
    );
    if (!mounted || token != _loadToken || mmData == null) {
      return;
    }
    final ui.Codec codec = await ui.instantiateImageCodec(mmData);
    if (!mounted || token != _loadToken) {
      codec.dispose();
      return;
    }
    final FrameInfo firstFrame = await codec.getNextFrame();
    if (!mounted || token != _loadToken) {
      firstFrame.image.dispose();
      codec.dispose();
      return;
    }
    _codec = codec;
    _firstFrmame = firstFrame;
    double imageH = firstFrame.image.height.toDouble();
    double imageW = firstFrame.image.width.toDouble();
    if (imageH != 0 && imageW != 0) {
      _realImageHeight = (widget.width ?? imageW) * imageH / imageW;
    }
    if (!mounted || token != _loadToken) {
      return;
    }
    setState(() {});
  }

  void _disposeImageResources() {
    _firstFrmame?.image.dispose();
    _firstFrmame = null;
    _codec?.dispose();
    _codec = null;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.width,
          height: widget.height ?? _realImageHeight ?? 0,
          color: NineImageBackground.resolveForGif(widget.backgroundColor),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: getImageWidget(),
          ),
        ),
      ),
    );
  }

  Widget getImageWidget() {
    if (_codec != null) {
      return Center(
        child: RepaintBoundary(
          child: GifPainterWidget(
            key: ValueKey(widget.url),
            url: widget.url,
            firstFrmame: _firstFrmame,
            codec: _codec!,
            fit: widget.fit ?? BoxFit.cover,
            alignment: Alignment.center,
            width: widget.width ?? double.infinity,
            height: widget.height ?? _realImageHeight ?? 0,
            radius: widget.radius,
            title: widget.title,
            autoSpeed: true,
          ),
        ),
      );
    } else {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: ClipRRect(
          borderRadius:
              widget.borderRadius ?? BorderRadius.circular(widget.radius),
          child: widget.placeholder,
        ),
      );
    }
  }
}
