import 'package:flutter/material.dart';

/// 当日时间戳：距本地 00:00 的毫秒数（0–86399999）。
class StoreTimeOfDayMs {
  StoreTimeOfDayMs._();

  static const defaultOpenMs = 9 * 3600 * 1000;
  static const defaultCloseMs = 22 * 3600 * 1000;

  static int fromTimeOfDay(TimeOfDay time) {
    return (time.hour * 3600 + time.minute * 60) * 1000;
  }

  static TimeOfDay toTimeOfDay(int ms) {
    final totalSeconds = ms ~/ 1000;
    return TimeOfDay(
      hour: totalSeconds ~/ 3600,
      minute: (totalSeconds % 3600) ~/ 60,
    );
  }

  static String format(int? ms) {
    if (ms == null) return '--:--';
    final time = toTimeOfDay(ms);
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static int? parse(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static int minuteOfDay(DateTime moment) {
    return moment.hour * 60 + moment.minute;
  }

  static int minuteFromMs(int ms) => ms ~/ 60000;

  /// 当前时刻是否在 [openMs, closeMs] 内（含起止分钟）。
  static bool isWithinRange(int openMs, int closeMs, DateTime moment) {
    final current = minuteOfDay(moment);
    final open = minuteFromMs(openMs);
    final close = minuteFromMs(closeMs);
    return current >= open && current <= close;
  }
}
