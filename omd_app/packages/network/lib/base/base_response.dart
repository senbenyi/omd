class NineBaseResponse {
  final dynamic data;
  final int code; // 业务 code
  final int statusCode; // httpCode
  final String statusMessage; // httpCode message
  final String message;
  final Map<String, dynamic>? params;
  final int currentPage;
  final int pageSize;
  final int totalNum;
  final int totalPage;
  final dynamic error;

  NineBaseResponse({
    this.data,
    this.code = 0,
    this.params,
    this.message = "",
    this.statusMessage = "",
    this.statusCode = 0,
    this.error,
    this.currentPage = 1,
    this.pageSize = 0,
    this.totalNum = 0,
    this.totalPage = 0,
  }) : super();

  bool get isSuccess {
    return code == 200;
  }
}

bool isNullValue(dynamic value) {
  return [null, "null", 0, "0", ""].contains(value);
}
