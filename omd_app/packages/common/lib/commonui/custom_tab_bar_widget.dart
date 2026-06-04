import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabItem {
  int index;
  String title;
  String iconPath;
  IconData? icon;
  dynamic value;

  TabItem({
    this.index = 0,
    this.value,
    this.title = "",
    this.iconPath = "",
    this.icon,
  });

  @override
  String toString() =>
      "{'title': $title, 'value': $value, 'index': $index, 'iconPath': $iconPath}";
}

typedef IndexedTabBuilder = Widget Function(int index, bool isSelected);

class CustomTabBarWidget extends StatelessWidget {
  final List<TabItem> tabs;
  final ValueChanged<TabItem>? onTap;
  final double horizontalPadding;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final TabController tabController;
  final BoxDecoration? selectedBackground;
  final BoxDecoration? unselectedBackground;
  final double? tabPadding;
  final double? labelPadding;
  final bool isCenter;
  final bool isScrollable;
  final IndexedTabBuilder? tabBuilder;

  const CustomTabBarWidget({
    super.key,
    required this.tabs,
    required this.tabController,
    this.onTap,
    this.labelPadding,
    this.horizontalPadding = 7,
    this.tabPadding = 2.0,
    this.selectedTextStyle = const TextStyle(color: Colors.white),
    this.unselectedTextStyle = const TextStyle(color: Colors.grey),
    this.selectedBackground,
    this.unselectedBackground,
    this.tabBuilder,
    this.isScrollable = true,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return TabBar(
          controller: tabController,
          isScrollable: isScrollable,
          dividerColor: Colors.transparent,
          indicator: const BoxDecoration(), // 去掉默认下划线
          labelPadding: EdgeInsets.symmetric(horizontal: labelPadding ?? 7.5.w),
          onTap: (index) {
            // if (tabController.index == index) return;// 🚀 防止重复点击
            final tab = tabs[index];
            tab.index = index;
            onTap?.call(tab);
          },
          tabs: List.generate(tabs.length, (index) {
            final selected = tabController.index == index;
            if (tabBuilder != null) {
              return tabBuilder!(index, selected);
            }
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: tabPadding ?? 4.0,
              ),
              decoration: selected ? selectedBackground : unselectedBackground,
              child: Text(
                tabs[index].title,
                style: selected ? selectedTextStyle : unselectedTextStyle,
              ),
            );
          }),
        );
      },
    );
  }
}
