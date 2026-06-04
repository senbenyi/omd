import 'package:store/module/store/store_models.dart';
import 'package:store/module/store/store_time_utils.dart';

/// 根据定休日与营业时间计算当前营业状态。
class StoreStatusHelper {
  StoreStatusHelper._();

  /// open=营业中 · closed=打烊 · rest=休息中（定休日）
  static String compute(StoreModel store, [DateTime? now]) {
    final moment = now ?? DateTime.now();
    final weekday = moment.weekday;

    if (_isClosedWeekday(store.closedWeekdays, weekday)) {
      return 'rest';
    }

    final hours = store.businessHours;
    if (hours.isOpen24Hours) {
      return 'open';
    }

    final openMs = hours.openTime;
    final closeMs = hours.closeTime;
    if (openMs == null || closeMs == null) {
      return 'closed';
    }

    if (StoreTimeOfDayMs.isWithinRange(openMs, closeMs, moment)) {
      return 'open';
    }
    return 'closed';
  }

  static bool _isClosedWeekday(List<int> weekdays, int weekday) {
    for (final day in weekdays) {
      if (day == weekday) {
        return true;
      }
    }
    return false;
  }
}

extension StoreModelComputedStatus on StoreModel {
  String get computedStatus => StoreStatusHelper.compute(this);
}
