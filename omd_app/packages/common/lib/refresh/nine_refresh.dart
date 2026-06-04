import 'dart:async';
import 'package:common/refresh/easy_refresh/easy_refresh.dart';
import 'package:base/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:base/utils/app_channel.dart';

class NineRefreshController {
  final bool controlFinishLoad;
  final bool controlFinishRefresh;
  late EasyRefreshController controller;
  NineRefreshController({
    this.controlFinishLoad = true,
    this.controlFinishRefresh = true,
  }) {
    controller = EasyRefreshController(
      controlFinishLoad: controlFinishLoad,
      controlFinishRefresh: controlFinishRefresh,
    );
  }

  void loadData() {
    controller.callLoad();
  }

  void refresh() {
    controller.callRefresh();
  }

  void finishRefresh() {
    controller.finishRefresh(IndicatorResult.success, true);
  }

  void finishLoad() {
    controller.finishLoad(IndicatorResult.success, true);
  }

  /// 加载失败时调用，停止加载动画并显示「加载失败」
  void finishLoadFail() {
    controller.finishLoad(IndicatorResult.fail, true);
  }

  void finishNoMore() async {
    controller.finishLoad(IndicatorResult.noMore, true);
  }

  /// 下拉刷新失败时调用，停止刷新动画并恢复到初始状态
  void finishRefreshFail() {
    controller.finishRefresh(IndicatorResult.fail, true);
  }

  /// 重置 footer 状态，用于切换日期/刷新后恢复「上拉加载更多」
  void resetFooter() {
    controller.resetFooter();
  }

  void dispose() {
    controller.dispose();
  }
}

class NineRefresh extends StatelessWidget {
  final FutureOr Function()? onRefresh;
  final FutureOr Function()? onLoad;
  final Widget? child;
  final NineRefreshController? controller;
  final bool enablePullUp;
  final bool safeArea;
  final Axis triggerAxis;
  /// 上拉到底且无更多数据时的文案；传空字符串则不展示底部提示文字（其它加载阶段文案不变）
  final String footerNoMoreText;
  const NineRefresh({
    super.key,
    this.controller,
    this.onRefresh,
    this.onLoad,
    this.child,
    this.enablePullUp = true,
    this.safeArea = true,
    this.triggerAxis = Axis.vertical,
    this.footerNoMoreText = '已加载全部内容',
  });

  bool get isDark => appChannel.themeMode == NineThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: controller?.controller,
      triggerAxis: triggerAxis,
      spring: const SpringDescription(
        mass: 1,
        stiffness: 1000, // ⭐ 数值越大，回弹越快（默认很小）
        damping: 100, // ⭐ 阻尼，防止抖动
      ),
      header: ClassicHeader(
        safeArea: safeArea,
        dragText: '下拉刷新',
        armedText: '松手即可刷新',
        processedText: '刷新成功',
        processingText: '',
        readyText: '',
        position: isDark ? IndicatorPosition.above : IndicatorPosition.behind,
        backgroundColor: Colors.transparent,
        textStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
        showMessage: false,
        spacing: 0,
        processedDuration: Duration.zero,

        pullIconBuilder: (context, state, animation) {
          return NinePullIconBuilder.buildIcon(
            context,
            state,
            animation,
            isDark: isDark,
          );
        },
      ),
      footer: ClassicFooter(
        dragText: '上拉加载',
        armedText: '松手即可加载',
        readyText: '',
        processingText: '',
        processedText: '',
        noMoreText: footerNoMoreText,
        failedText: '加载失败',
        backgroundColor: Colors.transparent,
        textStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
        showMessage: false,
        iconDimension: null,
        spacing: 0,
        textBuilder:
            footerNoMoreText.isEmpty
                ? (context, state, text) {
                  if (state.result == IndicatorResult.noMore) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    text,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  );
                }
                : null,
        pullIconBuilder: (context, state, animation) {
          return NinePullIconBuilder.buildIcon(
            context,
            state,
            animation,
            isDark: isDark,
          );
        },
      ),
      onRefresh: onRefresh,
      onLoad: onLoad,
      child: child,
    );
  }
}

/// 统一的下拉/上拉图标构建器
class NinePullIconBuilder {
  static Widget buildIcon(
    BuildContext context,
    IndicatorState state,
    double animation, {
    bool isDark = false,
  }) {
    Widget icon;
    final iconTheme = Theme.of(context).iconTheme;

    ValueKey iconKey;
    if (state.result == IndicatorResult.noMore) {
      iconKey = const ValueKey(IndicatorResult.noMore);
      icon = SizedBox();
    } else if (state.mode == IndicatorMode.processing ||
        state.mode == IndicatorMode.ready) {
      iconKey = const ValueKey(IndicatorMode.processing);
      final progressIndicatorSize = 22.0;
      icon = SizedBox(
        width: progressIndicatorSize,
        height: progressIndicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: isDark ? Colors.white : Colors.black,
        ),
      );
    } else if (state.mode == IndicatorMode.processed ||
        state.mode == IndicatorMode.done) {
      if (state.result == IndicatorResult.fail) {
        iconKey = const ValueKey(IndicatorResult.fail);
        icon = SizedBox();
      } else {
        iconKey = const ValueKey(IndicatorResult.success);
        icon = SizedBox();
      }
    } else {
      iconKey = const ValueKey(IndicatorMode.drag);
      icon = SizedBox();
    }
    return IconTheme(key: iconKey, data: iconTheme, child: icon);
  }
}
