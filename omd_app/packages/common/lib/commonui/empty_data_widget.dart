import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyDataWidget extends StatelessWidget {
  final String imageName;
  final String? message;
  final String? subMessage;
  final bool isLoading;

  const EmptyDataWidget({
    super.key,
    this.imageName = "",
    this.message,
    this.subMessage,
    this.isLoading = false,
  });
  @override
  Widget build(BuildContext context) {
    return isLoading ? loadingWidget() : noDataWidget();
  }

  Widget noDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SVG图标
          SvgPicture.asset(
            imageName.isNotEmpty
                ? imageName
                : 'packages/mg91/assets/public/empty_data.svg',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 20),
          // 文案
          Text(
            message ?? "暂无数据",
            style: TextStyle(fontSize: 14.sp, color: Color(0xFF666666)),
            textAlign: TextAlign.center,
          ),
          if (subMessage != null) ...[
            SizedBox(height: 4.w),
            Text(
              subMessage!,
              style: TextStyle(fontSize: 13.sp, color: Color(0xFF999999)),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget loadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2.0,
          ),
          SizedBox(height: 16),
          Text(
            message ?? '加载中...',
            style: TextStyle(fontSize: 16, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
}
