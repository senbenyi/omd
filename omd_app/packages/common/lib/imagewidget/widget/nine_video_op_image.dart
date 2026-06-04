import 'dart:ui' as ui;
import 'package:base/theme/app_theme.dart';
import 'package:base/utils/app_channel.dart';
import 'package:common/imagewidget/download_center/nine_image_provider.dart';
import 'package:common/imagewidget/nine_image_background.dart';
import 'package:common/imagewidget/ency_image_provider.dart';
import 'package:common/imagewidget/widget/gif_painter_widget.dart';
import 'package:common/imagewidget/widget/nine_op_image_tv_text_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NineVideoOpImage extends StatefulWidget {
  const NineVideoOpImage({
    super.key,
    required this.imageUrl,
    required this.trailUrl,
    this.title = "",
    this.width,
    this.height,
    this.fit = BoxFit.fill,
    this.placeholder,
    this.onTap,
    this.alignment,
    this.radius = 0,
    this.cacheWidth,
    this.cacheHeight,
    this.backgroundColor,
  });

  final String imageUrl;
  final String trailUrl;
  final String title;
  final Widget? placeholder;
  final double? width;
  final double? height;
  final Alignment? alignment;
  final BoxFit? fit;
  final VoidCallback? onTap;

  final double radius;
  final int? cacheWidth;
  final int? cacheHeight;
  final Color? backgroundColor;

  @override
  State<NineVideoOpImage> createState() => _NineVideoOpImageState();
}

class _NineVideoOpImageState extends State<NineVideoOpImage>
    with TickerProviderStateMixin {
  ui.Codec? _codec;
  ui.FrameInfo? _firstFrame;

  bool _showGif = false; // 当前已经展示 GIF
  bool _isLoading = false; // 正在加载 trailUrl
  bool showPlaceHolder = true;
  bool _trailLoadFailed = false;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrl.isEmpty && widget.trailUrl.isNotEmpty) {
      _loadTrailImage(); // 直接加载 GIF
    }
  }

  @override
  void didUpdateWidget(covariant NineVideoOpImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trailUrl != widget.trailUrl) {
      _reset();
      if (_showGif) _hideGif();
    }
  }

  bool _needDecryptCover() {
    if (appChannel.channleType == ChannelType.tv) {
      return true;
    }
    if (!widget.imageUrl.contains('.gif')) {
      return true;
    }
    return true;
  }

  void _reset() {
    _codec = null;
    _firstFrame = null;
    _showGif = false;
    _trailLoadFailed = false;
  }

  Future<void> _loadTrailImage() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _trailLoadFailed = false;
    });
    try {
      final data = await NineImageProvider.instance.requestImageData(
        widget.trailUrl,
        needDecrypt: true,
        compressImage: true,
        cacheWidth: widget.cacheWidth,
        title: widget.title,
      );

      if (!mounted) return;
      if (data == null || data.isEmpty) {
        setState(() {
          _isLoading = false;
          _trailLoadFailed = true;
        });
        return;
      }

      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();
      if (!mounted) return;

      _codec = codec;
      _firstFrame = frame;
      _showGif = true;
      setState(() {
        _isLoading = false;
        _trailLoadFailed = false;
        showPlaceHolder = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _trailLoadFailed = true;
      });
    }
  }

  void _hideGif() {
    _showGif = false;
    setState(() {});
  }

  /// 与 [NineopImage] 未成帧占位一致：TV 用文字扫光，其余用波浪扫光。
  Widget _buildCoverLoadingVisual() {
    if (appChannel.channleType == ChannelType.tv) {
      return NineOpImageTvTextShimmer(
        label: widget.title.trim().isEmpty ? null : widget.title.trim(),
      );
    }
    return widget.placeholder ?? SizedBox.shrink();
  }

  Color get _backgroundColor =>
      NineImageBackground.resolve(widget.backgroundColor);

  /// 无业务 [placeholder] 时用占位底色，避免错误态全透明。
  Widget _buildCoverErrorVisual() {
    if (widget.placeholder != null) {
      return IgnorePointer(child: widget.placeholder!);
    }
    return ColoredBox(color: _backgroundColor);
  }

  Widget _buildStaticImage() {
    return VisibilityDetector(
      key: ValueKey(widget.imageUrl),
      onVisibilityChanged: (info) {
        final visible = info.visibleFraction > 0.1;
        NineImageProvider.instance.changePriority(
          widget.imageUrl,
          visible ? 2 : 1,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        clipBehavior: Clip.hardEdge,
        child: ColoredBox(
          color: _backgroundColor,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: _buildStaticContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildStaticContent() {
    final image = Image(
      image: EncryptedImageProvider(
        url: widget.imageUrl,
        isAd: false,
        cacheWidth: widget.cacheWidth,
        cacheHeight: widget.cacheHeight,
        needDecrypt: _needDecryptCover(),
        compressImage: true,
        title: widget.title,
      ),
      fit: widget.fit ?? BoxFit.cover,
      alignment: widget.alignment ?? Alignment.topCenter,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return SizedBox.expand(child: _buildCoverLoadingVisual());
      },
      frameBuilder: (
        BuildContext context,
        Widget child,
        int? frame,
        bool wasSynchronouslyLoaded,
      ) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 500),
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (widget.placeholder != null) {
          return const SizedBox.shrink();
        }
        return SizedBox.expand(child: _buildCoverErrorVisual());
      },
    );

    if (widget.placeholder == null) {
      return image;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW =
            _finiteOrNull(widget.width) ?? _finiteOrNull(constraints.maxWidth);
        final maxH =
            _finiteOrNull(widget.height) ??
            _finiteOrNull(constraints.maxHeight);

        if (maxW != null && maxH != null) {
          return SizedBox(
            width: maxW,
            height: maxH,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(child: widget.placeholder!),
                Positioned.fill(child: image),
              ],
            ),
          );
        }

        return Stack(
          fit: StackFit.passthrough,
          children: [Positioned.fill(child: widget.placeholder!), image],
        );
      },
    );
  }

  static double? _finiteOrNull(double? value) {
    if (value == null || !value.isFinite) return null;
    return value;
  }

  Widget _buildGifWidget() {
    if (_codec == null || _firstFrame == null) return const SizedBox();
    return GifPainterWidget(
      codec: _codec!,
      firstFrmame: _firstFrame!,
      fit: widget.fit ?? BoxFit.cover,
      alignment: widget.alignment ?? Alignment.center,
      width: widget.width ?? double.infinity,
      height: widget.width ?? double.infinity,
      url: widget.trailUrl,
      title: widget.title,
      autoSpeed: false,
      radius: widget.radius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        //  已经展示 GIF 或正在加载 GIF → 执行 onTap
        if (_showGif || _isLoading) {
          widget.onTap?.call();
          return;
        }
        // 规则 2：静态图状态 → 加载 GIF
        if (widget.trailUrl.isNotEmpty) {
          _loadTrailImage();
          return;
        }
        widget.onTap?.call();
      },
      child: ColoredBox(
        color: _backgroundColor,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            children: [
              _buildStaticImage(),
            AnimatedOpacity(
              opacity: _firstFrame == null ? 0 : 1,
              duration: Duration(milliseconds: 500),
              child: _firstFrame == null ? SizedBox() : _buildGifWidget(),
            ),

            if (_trailLoadFailed)
              Positioned.fill(
                child: IgnorePointer(child: _buildCoverErrorVisual()),
              )
            else if (_isLoading)
              Positioned.fill(
                child: IgnorePointer(child: _buildCoverLoadingVisual()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
