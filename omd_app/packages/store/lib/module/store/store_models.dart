import 'package:store/module/store/store_i18n.dart';
import 'package:store/module/store/store_time_utils.dart';

/// 门店相关数据模型，与 [omd_api.openapi.yaml] 对齐。

class StoreBusinessHours {
  StoreBusinessHours({
    required this.isOpen24Hours,
    this.openTime,
    this.closeTime,
  });

  factory StoreBusinessHours.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StoreBusinessHours.defaults();
    }
    return StoreBusinessHours(
      isOpen24Hours: json['isOpen24Hours'] == true,
      openTime: StoreTimeOfDayMs.parse(json['openTime']),
      closeTime: StoreTimeOfDayMs.parse(json['closeTime']),
    );
  }

  factory StoreBusinessHours.defaults() {
    return StoreBusinessHours(
      isOpen24Hours: false,
      openTime: StoreTimeOfDayMs.defaultOpenMs,
      closeTime: StoreTimeOfDayMs.defaultCloseMs,
    );
  }

  final bool isOpen24Hours;
  final int? openTime;
  final int? closeTime;

  Map<String, dynamic> toJson() {
    return {
      'isOpen24Hours': isOpen24Hours,
      if (!isOpen24Hours) 'openTime': openTime,
      if (!isOpen24Hours) 'closeTime': closeTime,
    };
  }
}

class StoreServiceInfo {
  StoreServiceInfo({
    required this.serviceExpireAt,
    required this.vipLevel,
    this.referrerId,
    required this.additionalPeriod,
  });

  factory StoreServiceInfo.fromJson(Map<String, dynamic> json) {
    return StoreServiceInfo(
      serviceExpireAt: json['serviceExpireAt'] as String? ?? '',
      vipLevel: _parseInt(json['vipLevel']),
      referrerId: json['referrerId'] as String?,
      additionalPeriod: _parseInt(json['additionalPeriod']),
    );
  }

  final String serviceExpireAt;
  final int vipLevel;
  final String? referrerId;
  final int additionalPeriod;

  Map<String, dynamic> toJson() {
    return {
      'serviceExpireAt': serviceExpireAt,
      'vipLevel': vipLevel,
      if (referrerId != null) 'referrerId': referrerId,
      'additionalPeriod': additionalPeriod,
    };
  }
}

class StoreModel {
  StoreModel({
    required this.id,
    this.userId,
    required this.name,
    required this.status,
    required this.address,
    required this.phone,
    required this.contactName,
    required this.businessHours,
    required this.closedWeekdays,
    required this.serviceInfo,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    final serviceRaw = json['serviceInfo'];
    final hoursRaw = json['businessHours'];
    return StoreModel(
      id: _parseInt(json['id']),
      userId: json['userId'] == null ? null : _parseInt(json['userId']),
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'rest',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      contactName: json['contactName'] as String? ?? '',
      businessHours:
          hoursRaw is Map
              ? StoreBusinessHours.fromJson(
                Map<String, dynamic>.from(hoursRaw as Map),
              )
              : StoreBusinessHours.defaults(),
      closedWeekdays: _parseWeekdays(json['closedWeekdays']),
      serviceInfo:
          serviceRaw is Map
              ? StoreServiceInfo.fromJson(
                Map<String, dynamic>.from(serviceRaw as Map),
              )
              : StoreServiceInfo(
                serviceExpireAt: '',
                vipLevel: 1,
                additionalPeriod: 0,
              ),
    );
  }

  final int id;
  final int? userId;
  final String name;
  final String status;
  final String address;
  final String phone;
  final String contactName;
  final StoreBusinessHours businessHours;
  final List<int> closedWeekdays;
  final StoreServiceInfo serviceInfo;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'name': name,
      'status': status,
      'address': address,
      'phone': phone,
      'contactName': contactName,
      'businessHours': businessHours.toJson(),
      'closedWeekdays': closedWeekdays,
      'serviceInfo': serviceInfo.toJson(),
    };
  }
}

class SaveStoreRequest {
  SaveStoreRequest({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.contactName,
    required this.vipLevel,
    this.referrerId,
    this.businessHours,
    this.closedWeekdays,
  });

  final int? id;
  final String name;
  final String address;
  final String phone;
  final String contactName;
  final int vipLevel;
  final String? referrerId;
  final StoreBusinessHours? businessHours;
  final List<int>? closedWeekdays;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'contactName': contactName,
      'vipLevel': vipLevel,
      if (referrerId != null && referrerId!.isNotEmpty) 'referrerId': referrerId,
      if (businessHours != null) 'businessHours': businessHours!.toJson(),
      if (closedWeekdays != null) 'closedWeekdays': closedWeekdays,
    };
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

List<int> _parseWeekdays(dynamic value) {
  if (value is! List) return [];
  return value.map(_parseInt).where((d) => d >= 1 && d <= 7).toList();
}

/// 营业状态选项。
class StoreStatusOption {
  const StoreStatusOption(this.value, this.labelKey);

  final String value;
  final String labelKey;

  static const options = [
    StoreStatusOption('open', StoreStoreI18n.statusOpen),
    StoreStatusOption('closed', StoreStoreI18n.statusClosed),
    StoreStatusOption('rest', StoreStoreI18n.statusRest),
  ];
}

/// 定休日：1=周一 … 7=周日（与 Dart [DateTime.weekday] 一致）。
class StoreWeekdayOption {
  const StoreWeekdayOption(this.value, this.labelKey);

  final int value;
  final String labelKey;

  static const options = [
    StoreWeekdayOption(1, StoreStoreI18n.weekdayMon),
    StoreWeekdayOption(2, StoreStoreI18n.weekdayTue),
    StoreWeekdayOption(3, StoreStoreI18n.weekdayWed),
    StoreWeekdayOption(4, StoreStoreI18n.weekdayThu),
    StoreWeekdayOption(5, StoreStoreI18n.weekdayFri),
    StoreWeekdayOption(6, StoreStoreI18n.weekdaySat),
    StoreWeekdayOption(7, StoreStoreI18n.weekdaySun),
  ];

  static String labelFor(int weekday) {
    for (final option in options) {
      if (option.value == weekday) {
        return option.labelKey;
      }
    }
    return '$weekday';
  }
}
