class CustomerApiResponse<T> {
  CustomerApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  final String code;
  final String message;
  final T? data;

  bool get isSuccess => code == '0';
}
