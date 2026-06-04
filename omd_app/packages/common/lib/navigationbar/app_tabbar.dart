import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base/theme/app_theme.dart';

class AppTabbar extends StatelessWidget {
  final int tabBarIndex;
  final double tabBarHeight;
  final EdgeInsets? padding;
  final EdgeInsets labelPadding;
  final List<String> tabs;
  final TabController? tabController;
  final TextStyle labelStyle;
  final TextStyle unselectedLabelStyle;
  final bool showIndicator;
  final Color backgroundColor;
  final Color? indicatorColor;
  final ValueChanged<int>? onChange;
  final String keyword;
  final Color keywordColor;
  final TabAlignment tabAlignment;
  final AlignmentGeometry? alignment;
  final bool isScrollable;
  final double borderSide;
  const AppTabbar({
    super.key,
    this.padding,
    required this.tabs,
    this.tabController,
    this.showIndicator = true,
    this.isScrollable = true,
    this.tabAlignment = TabAlignment.start,
    this.alignment,
    this.backgroundColor = Colors.transparent,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.labelStyle = const TextStyle(
      color: Colors.black,
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
    this.unselectedLabelStyle = const TextStyle(
      color: Colors.black54,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    this.indicatorColor,
    this.tabBarHeight = 44,
    this.onChange,
    this.tabBarIndex = 0,
    this.borderSide = 3,
    this.keyword = '',
    this.keywordColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    String text = tabs[tabBarIndex];
    bool boo = text == keyword;
    Widget tabBar = TabBar(
      controller: tabController,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      isScrollable: isScrollable,
      tabAlignment: tabAlignment,
      indicatorSize: showIndicator ? TabBarIndicatorSize.label : null,
      indicator:
          showIndicator
              ? UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 3,
                  color:
                      boo
                          ? keywordColor
                          : indicatorColor ?? appColor.tabIndicatorColor,
                ),
                borderRadius: BorderRadius.circular(8.r),
                insets: EdgeInsets.symmetric(horizontal: 5.w),
              )
              : BoxDecoration(),
      // labelColor: Colors.white,
      // unselectedLabelColor: Colors.black,
      labelStyle: labelStyle,
      unselectedLabelStyle: unselectedLabelStyle,
      labelPadding: labelPadding,
      dividerColor: Colors.transparent,
      tabs: List.generate(tabs.length, (index) {
        String text = tabs[index];
        bool boo = text == keyword;
        if (boo) {
          return Tab(
            child: Text(
              text,
              style: TextStyle(
                color: boo ? keywordColor : null,
                fontFamily: boo ? 'HYYakuHei' : '',
              ),
            ),
          );
        }
        return Tab(text: text);
      }),
      onTap: onChange,
    );
    if (tabController == null) {
      tabBar = DefaultTabController(length: tabs.length, child: tabBar);
    }
    return Container(
      width: double.infinity,
      height: tabBarHeight.w,
      alignment: alignment,
      padding: padding ?? EdgeInsets.only(bottom: 8.w),
      color: backgroundColor,
      child: tabBar,
    );
  }
}
