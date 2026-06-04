import 'package:store/module/login/store_auth_models.dart';

class GoUserLoginModel {
  GoUserLoginModel({
    required this.userId,
    this.userIdStr,
    this.account,
    this.token,
    required this.tokenExpires,
    this.phone,
    this.countryCode,
    this.email,
    this.fullName,
  });

  factory GoUserLoginModel.fromJson(Map<String, dynamic> json) {
    if (_isOpenApiFormat(json)) {
      return GoUserLoginModel.fromOpenApiJson(json);
    }
    return GoUserLoginModel(
      userId: json['ui'] as int? ?? 0,
      account: json['un'] as String?,
      token: json['tk'] as String?,
      tokenExpires: json['te'] as int? ?? 0,
      phone: json['pn'] as String?,
      countryCode: json['cc'] as String?,
      email: json['em'] as String?,
      fullName: json['fn'] as String?,
    );
  }

  factory GoUserLoginModel.fromOpenApiJson(Map<String, dynamic> json) {
    final rawUserId = json['userId']?.toString() ?? '';
    final parsedId = int.tryParse(rawUserId) ?? 0;
    final username = json['username'] as String?;
    return GoUserLoginModel(
      userId: parsedId,
      userIdStr: rawUserId.isNotEmpty ? rawUserId : null,
      account: username,
      token: json['token'] as String?,
      tokenExpires: 0,
      phone: json['phone'] as String?,
      fullName: username,
    );
  }

  factory GoUserLoginModel.fromAuthData(StoreAuthData data) {
    return GoUserLoginModel.fromOpenApiJson(data.toJson());
  }

  final int userId;
  final String? userIdStr;
  final String? account;
  final String? token;
  final int tokenExpires;
  final String? phone;
  final String? countryCode;
  final String? email;
  final String? fullName;

  String get displayUserId =>
      userIdStr ?? (userId > 0 ? userId.toString() : '0');

  String? get displayName => fullName ?? account;

  bool get hasLoginIdentity =>
      userId > 0 ||
      (userIdStr?.isNotEmpty ?? false) ||
      (token?.isNotEmpty ?? false);

  Map<String, dynamic> toJson() {
    if (userIdStr != null || (token?.isNotEmpty ?? false)) {
      return {
        'userId': userIdStr ?? userId.toString(),
        'username': fullName ?? account,
        'token': token,
        'phone': phone,
      };
    }
    return {
      'ui': userId,
      'un': account,
      'tk': token,
      'te': tokenExpires,
      'pn': phone,
      'cc': countryCode,
      'em': email,
      'fn': fullName,
    };
  }

  static bool _isOpenApiFormat(Map<String, dynamic> json) {
    return json.containsKey('token') &&
        (json.containsKey('userId') || json.containsKey('username'));
  }
}
