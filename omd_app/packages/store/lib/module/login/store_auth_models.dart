/// 与 [omd_api.openapi.yaml] 认证接口对齐的请求/响应模型。

/// 统一业务响应：`{ code, message, data }`，`code` 为 string，`"0"` 表示成功。
class StoreApiResponse<T> {
  StoreApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory StoreApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? dataParser,
  ) {
    final rawData = json['data'];
    T? parsed;
    if (dataParser != null && rawData is Map<String, dynamic>) {
      parsed = dataParser(rawData);
    }
    return StoreApiResponse<T>(
      code: json['code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: parsed,
    );
  }

  final String code;
  final String message;
  final T? data;

  bool get isSuccess => code == '0';

  Map<String, dynamic> toJson([Object? Function(T value)? dataEncoder]) {
    return {
      'code': code,
      'message': message,
      'data':
          data == null
              ? null
              : dataEncoder != null
              ? dataEncoder(data as T)
              : (data as StoreAuthData).toJson(),
    };
  }

  static StoreApiResponse<T> success<T>(T data, {String message = 'ok'}) {
    return StoreApiResponse<T>(code: '0', message: message, data: data);
  }

  static StoreApiResponse<T> failure<T>({
    required String code,
    required String message,
  }) {
    return StoreApiResponse<T>(code: code, message: message);
  }
}

/// POST /auth/login 请求体。
class StoreAuthLoginRequest {
  StoreAuthLoginRequest({
    required this.phone,
    required this.password,
  });

  final String phone;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
    };
  }
}

/// POST /auth/register 请求体。
class StoreAuthRegisterRequest {
  StoreAuthRegisterRequest({
    required this.phone,
    required this.password,
    this.username,
  });

  final String phone;
  final String password;
  final String? username;

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
      if (username != null && username!.isNotEmpty) 'username': username,
    };
  }
}

/// 登录/注册成功后的 `data` 字段。
class StoreAuthData {
  StoreAuthData({
    required this.token,
    required this.userId,
    required this.username,
    required this.phone,
  });

  factory StoreAuthData.fromJson(Map<String, dynamic> json) {
    return StoreAuthData(
      token: json['token'] as String? ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  final String token;
  final String userId;
  final String username;
  final String phone;

  bool get hasLoginIdentity =>
      token.isNotEmpty && (userId.isNotEmpty || username.isNotEmpty);

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userId': userId,
      'username': username,
      'phone': phone,
    };
  }
}
