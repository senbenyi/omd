import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base/theme/app_theme.dart';

class TabBarImageIndicator extends StatefulWidget {
  final TabController? controller;
  final List<String> list;
  final String indicatorUrl;
  final ValueChanged<int>? onChange;

  const TabBarImageIndicator({
    super.key,
    this.controller,
    required this.list,
    required this.indicatorUrl,
    this.onChange,
  });

  @override
  State<TabBarImageIndicator> createState() => _TabBarImageIndicatorState();
}

class _TabBarImageIndicatorState extends State<TabBarImageIndicator> {
  ui.Image? image;

  @override
  void initState() {
    super.initState();
    if (widget.indicatorUrl.isNotEmpty) loadIndicator();
  }

  void loadIndicator() async {
    ByteData data = await rootBundle.load(widget.indicatorUrl);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo frame = await codec.getNextFrame();
    setState(() => image = frame.image);
  }

  @override
  Widget build(BuildContext context) {
    Widget tabBar = TabBar(
      controller: widget.controller,
      isScrollable: true,
      tabAlignment: TabAlignment.center,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      indicator:
          image != null
              ? ImageIndicator(image: image!, height: 8.w, offset: 11.w)
              : BoxDecoration(),
      labelColor: appColor.cardTitle,
      unselectedLabelColor: appColor.cardTitle,
      labelStyle: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontSize: 17.sp),
      labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
      tabs: List.generate(widget.list.length, (index) {
        return Tab(text: widget.list[index]);
      }),
      onTap: widget.onChange,
    );
    if (widget.controller == null) {
      tabBar = DefaultTabController(length: widget.list.length, child: tabBar);
    }
    return tabBar;
  }
}

class ImageIndicator extends Decoration {
  final double height;
  final double offset;
  final ui.Image image;

  const ImageIndicator({
    required this.image,
    this.height = 12,
    this.offset = 0,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _ImageIndicatorPainter(this);
  }
}

class _ImageIndicatorPainter extends BoxPainter {
  final ImageIndicator decoration;

  _ImageIndicatorPainter(this.decoration);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final image = decoration.image;
    final double tabWidth = config.size!.width;
    final double tabHeight = config.size!.height;
    final double imageWidth = image.width * decoration.height / image.height;
    final double left = offset.dx + (tabWidth - imageWidth) / 2;
    final double top =
        offset.dy + tabHeight - decoration.height - decoration.offset;
    canvas.drawImageRect(
      image,
      Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(left, top, imageWidth, decoration.height),
      Paint(),
    );
  }
}
