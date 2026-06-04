import 'package:base/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:common/const/app_dimen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///文字超出一定行，自动隐藏，并添加入"...查看更多详情"为它设置点击事件
class HideText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final String? additionText;
  final TextStyle? additionStyle;
  final int maxLines;
  final String? additionUrl;
  final Map<String, dynamic>? additionParams;

  const HideText({
    super.key,
    required this.text, //正常字
    this.style, //正常字样式
    this.additionText = "展开", //附加字，如点击查看更多
    this.additionStyle, //附加字的样式
    this.maxLines = 3, //行数，不传 默认为3
    this.additionUrl, //点击附加字跳转URL
    this.additionParams, //点击附加字跳转时携带的参数
  });

  @override
  State<HideText> createState() => _HideTextState();
}

class _HideTextState extends State<HideText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (_expanded) {
      // 点击后展开显示
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(widget.text, style: widget.style),
      );
    }

    // 先测量是否超出 maxLines
    var exceeds =
        _textPaint([
          TextSpan(text: widget.text, style: widget.style),
        ]).didExceedMaxLines;

    if (!exceeds) {
      // 没超，直接显示
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(widget.text, style: widget.style),
      );
    }

    return Container(
      padding: EdgeInsets.only(top: 10),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: widget.text.substring(0, _fontNum()),
              style: widget.style,
            ),
            TextSpan(
              children: [
                TextSpan(text: "...", style: widget.additionStyle),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _expanded = true;
                      });
                      debugPrint("点击了");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${widget.additionText}",
                          style: widget.additionStyle,
                        ),
                        SizedBox(width: 2),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 16.w,
                            color: appColor.cardSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextPainter _textPaint(List<InlineSpan> children) {
    return TextPainter(
      maxLines: widget.maxLines,
      text: TextSpan(children: children),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: AppDimen.screenWidth - 40); //若新功能宽度不一致，可尝试修改，
    //UIUtils.screenWidth(context)是自定义的获取屏幕宽度的方法
  }

  int _fontNum() {
    //计算最多可容纳正常字的数目，可优化
    int num = 0;
    int skip = 1;
    while (true) {
      bool isExceed =
          widget.text.length < num + skip ||
          _textPaint([
            TextSpan(
              text: "${widget.text.substring(0, num + skip)}...",
              style: widget.style,
            ),
            TextSpan(text: widget.additionText, style: widget.additionStyle),
          ]).didExceedMaxLines;
      if (!isExceed) {
        num = num + skip;
        skip *= 2;
        continue;
      }
      if (isExceed && skip == 1) {
        return num;
      }
      skip = skip ~/ 2;
    }
  }
}
