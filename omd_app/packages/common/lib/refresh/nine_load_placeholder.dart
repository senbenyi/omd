import 'package:common/refresh/mg_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum NineLoadStatus { none, loading, noData, hasData, error }

class NineLoadPlaceholder extends StatelessWidget {
  final NineLoadController controller;
  final bool isDark;
  final Widget child;
  final bool isSliver;
  const NineLoadPlaceholder({
    super.key,
    required this.controller,
    this.isDark = false,
    required this.child,
    this.isSliver = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(color: Colors.red, child: _buildPlaceWidget());
      },
    );
  }

  Widget _buildPlaceWidget() {
    if (controller.status == NineLoadStatus.loading) {
      return buildLoading(isDarkMode: isDark);
    } else if (controller.status == NineLoadStatus.noData) {
      return buildEmpty(isDarkMode: isDark);
    } else if (controller.status == NineLoadStatus.error) {
      return buildError(
        controller.message,
        onRetry: controller.onRetry,
        isDarkMode: isDark,
      );
    } else {
      return child;
    }
  }

  static Widget buildLoading({bool isDarkMode = false}) {
    return Center(child: MG51AnimatedLogo());
  }

  static Widget buildEmpty({bool isDarkMode = false}) {
    return Center(
      child: Container(
        color: isDarkMode ? const Color(0xFF121212) : Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 60,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            SizedBox(height: 12.h),
            Text(
              '暂无数据',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildError(
    String message, {
    Function()? onRetry,
    bool isDarkMode = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(color: Colors.white54, fontSize: 16.sp),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF232325),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Text(
                '重试',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NineLoadController extends ChangeNotifier {
  NineLoadStatus _status = NineLoadStatus.none;
  String message = "";
  Function()? onRetry;
  int dataUptime = 0;

  Function()? onChange;

  String get stateKey {
    return 'refresh_${_status}_${message}_$dataUptime';
  }

  void loading() {
    _setStatus(NineLoadStatus.loading);
  }

  void hasData() {
    _setStatus(NineLoadStatus.hasData);
  }

  void error(String message) {
    _setStatus(NineLoadStatus.error, msg: message);
  }

  void _setStatus(NineLoadStatus value, {String msg = ""}) {
    bool changed = (value != _status || message != msg);
    if (value != NineLoadStatus.error) {
      message = "";
      dataUptime = DateTime.now().millisecondsSinceEpoch;
    } else {
      message = msg.isNotEmpty ? msg : "加载失败,稍后再试";
    }
    _status = value;
    if (changed) notifyListeners();
  }

  NineLoadStatus get status => _status;
}
