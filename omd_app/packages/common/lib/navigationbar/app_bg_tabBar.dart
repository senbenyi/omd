import 'package:base/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base/utils/app_channel.dart';

class AppBgTabbar extends StatefulWidget {
  final TabController? tabController;
  final List<String> tabs;
  final int tabBarIndex;
  final double? tabBarHeight;
  final EdgeInsets? padding;
  final ValueChanged<int>? onChange;

  const AppBgTabbar({
    super.key,
    this.tabController,
    required this.tabs,
    this.tabBarIndex = 0,
    this.tabBarHeight,
    this.padding,
    this.onChange,
  });

  @override
  State<AppBgTabbar> createState() => _AppBgTabbarState();
}

class _AppBgTabbarState extends State<AppBgTabbar> {
  int selectIndex = 0;
  @override
  void initState() {
    super.initState();
    selectIndex = widget.tabBarIndex;
    if (widget.tabController != null) {
      selectIndex = widget.tabController!.index;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isBorder = appChannel.channleType == ChannelType.tianyashequ;
    Widget tabBar = TabBar(
      controller: widget.tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: BoxDecoration(),
      labelStyle: TextStyle(
        fontSize: 12.sp,
        color: appColor.tabSelectTextColor,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12.sp,
        color: appColor.tabBarText,
      ),
      labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
      dividerColor: Colors.transparent,
      tabs: List.generate(widget.tabs.length, (index) {
        bool boo = selectIndex == index;
        return Tab(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  isBorder
                      ? Colors.transparent
                      : boo
                      ? appColor.tabSelectBgColor
                      : appColor.tabBarBg,
              borderRadius: BorderRadius.circular(4.r),
              border:
                  isBorder
                      ? Border.all(width: 0.5, color: Color(0xff2F3336))
                      : null,
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(widget.tabs[index]),
          ),
        );
      }),
      onTap: (index) {
        setState(() {
          selectIndex = index;
        });
        widget.onChange?.call(index);
      },
    );
    if (widget.tabController == null) {
      tabBar = DefaultTabController(
        length: widget.tabs.length,
        initialIndex: widget.tabBarIndex,
        child: tabBar,
      );
    }
    return Container(
      width: double.infinity,
      height: widget.tabBarHeight ?? 40.w,
      padding: widget.padding ?? EdgeInsets.symmetric(vertical: 7.w),
      child: tabBar,
    );
  }
}
