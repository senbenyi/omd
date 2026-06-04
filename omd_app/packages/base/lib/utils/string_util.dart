class StringUtil {
  StringUtil._();

  static bool isNotEmpty(String? str) {
    return str != null && str != '';
  }

  static bool isEmpty(String? str) {
    return str == null || str == '';
  }

  // 点赞、观看次数使用：>= 1w 显示两位小数并追加 W，否则返回原值
  static String formatViewCount(int number, {int decimalPlaces = 2}) {
    if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(decimalPlaces)}W';
    }
    return number % 1 == 0 ? '${number.toInt()}' : number.toString();
  }

  static String formatNumber(int number, {int decimalPlaces = 2}) {
    String formatCount = number.toString();
    if (number >= 10000) {
      formatCount =
          '${(double.parse(number.toString()) / 10000).toStringAsFixed(decimalPlaces)}W';
    }
    return formatCount;
  }

  static String formatDuration(String? duration) {
    if (isEmpty(duration)) return '00:00:00';
    final durationSeconds = int.parse(duration!);
    if (durationSeconds > 0) {
      if (durationSeconds >= 3600) {
        final hours = durationSeconds ~/ 3600;
        final minutes = (durationSeconds % 3600) ~/ 60;
        final seconds = durationSeconds % 60;
        return '${hours.toString().padLeft(2, '0')}:'
            '${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}';
      } else if (durationSeconds >= 60) {
        final minutes = durationSeconds ~/ 60;
        final seconds = durationSeconds % 60;
        return '${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}';
      } else {
        return "00:$durationSeconds";
      }
    } else {
      return '00:00:00';
    }
  }

  /// - 如果是 null 或空字符串，则返回空字符串。
  /// - 支持两种格式：
  ///   1. 以 "720p"、"1080P" 结尾的字符串。
  ///   2. 标准分辨率格式如 "1920x1080"、"1280X720"、"1280*720"。
  static String classifyResolution(String? resolution) {
    if (resolution == null || resolution.isEmpty) {
      return '';
    }

    // 去除所有空格
    final cleanedResolution = resolution.replaceAll(RegExp(r'\s+'), '');

    // 匹配以 720p、1080P 等结尾的格式
    final pFormatMatch = RegExp(r'^(\d+)[Pp]$').firstMatch(cleanedResolution);
    if (pFormatMatch != null) {
      final height = int.parse(pFormatMatch.group(1)!);
      if (height <= 480) {
        return '720P';
      } else if (height <= 720) {
        return '720P';
      } else {
        return '1080P';
      }
    }

    // 匹配像 1920x1080、1280*720、1280X720 这样的格式
    final match = RegExp(r'(\d+)[xX*&](\d+)').firstMatch(cleanedResolution);
    if (match != null) {
      final height = int.parse(match.group(2)!);
      if (height <= 480) {
        return '720P';
      } else if (height <= 720) {
        return '720P';
      } else {
        return '1080P';
      }
    }
    // 默认返回空字符串
    return '';
  }

  static String formatDecimal(double number, int position) {
    var temp = number.toString();
    if ((temp.length - temp.lastIndexOf('.') - 1) <= position) {
      return number.toStringAsFixed(position);
    } else {
      return temp.substring(0, temp.lastIndexOf('.') + position + 1);
    }
  }

  /// 判断当前字符串转换成长度（中文算作2个字符）
  static int stringLength(String str) {
    int tempLength = 0;
    if (str.isNotEmpty) {
      List<dynamic> tempList = str.split("");
      for (var i = 0; i < tempList.length; i++) {
        RegExp chinese = RegExp(r"[\u4e00-\u9fa5]");
        bool isChinese = chinese.hasMatch(tempList[i]);
        if (isChinese) {
          tempLength += 2;
        } else {
          tempLength += 1;
        }
      }
    }
    return tempLength;
  }

  /// 格式化相对时间的工具方法
  static String formatRelativeTime(String timeStr) {
    final now = DateTime.now();
    final date = DateTime.tryParse(timeStr);

    if (date == null) return "";

    final diff = now.difference(date);

    // ✅ 刚刚（< 1分钟）
    if (diff.inSeconds < 60) {
      return "刚刚";
    }

    // ✅ 分钟前（1分钟 - 59分钟）
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes}分钟前";
    }

    // ✅ 小时前（1小时 - 23小时59分钟）
    // 只要未超过24小时就显示小时前
    if (diff.inHours < 24) {
      return "${diff.inHours}小时前";
    }

    // ✅ 天前（1天 - 29天）
    if (diff.inDays < 30) {
      return "${diff.inDays}天前";
    }

    // ✅ 月前（1个月 - 11个月）
    if (diff.inDays < 365) {
      return "${(diff.inDays / 30).floor()}个月前";
    }

    // ✅ 年前（>= 1年）
    return "${(diff.inDays / 365).floor()}年前";
  }

  static String formatDuration2(Duration position) {
    final ms = position.inMilliseconds;

    int seconds = ms ~/ 1000;
    final int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    var minutes = seconds ~/ 60;
    seconds = seconds % 60;

    final hoursString =
        hours >= 10
            ? '$hours'
            : hours == 0
            ? '00'
            : '0$hours';

    final minutesString =
        minutes >= 10
            ? '$minutes'
            : minutes == 0
            ? '00'
            : '0$minutes';

    final secondsString =
        seconds >= 10
            ? '$seconds'
            : seconds == 0
            ? '00'
            : '0$seconds';

    final formattedTime =
        '${hoursString == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';

    return formattedTime;
  }

  /// 将日期格式化为 MM-DD 格式
  static String formatDate(String dateStr) {
    if (isEmpty(dateStr)) return '';

    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';

    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$month-$day';
  }

  static String formatDateToYMD(String datetime) {
    try {
      // 替换 / 为 -，保证兼容 "2025/07/23 15:30:45"
      DateTime date = DateTime.parse(datetime.replaceAll("/", "-"));
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return datetime; // 如果解析失败就返回原始数据
    }
  }

  static String getCurrentDateYMD() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  /// 判断一个 URL 是否是 Kiwi 转化的本地域名（127.开头的本地回环地址）
  /// 支持：
  ///   http://127.77.77.1:38291/xxx
  ///   http://127.0.0.1:52841/xxx
  ///   http://localhost:8080/xxx
  ///   以及各种非法/空值安全处理
  static bool isLocalUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    try {
      final uri = Uri.parse(url.trim());
      final host = uri.host;

      // 情况1：localhost 或 127.0.0.1
      if (host == 'localhost' || host == '127.0.0.1') {
        return true;
      }

      // 情况2：所有 127.x.x.x 形式的地址（Kiwi 最常用的）
      if (host.startsWith('127.')) {
        // 再严谨一点：确保是合法的四个数字段
        final parts = host.split('.');
        if (parts.length == 4 &&
            parts[0] == '127' &&
            parts
                .sublist(1)
                .every(
                  (part) =>
                      int.tryParse(part) != null &&
                      int.parse(part) >= 0 &&
                      int.parse(part) <= 255,
                )) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false; // 解析失败，肯定不是合法 URL
    }
  }
}
