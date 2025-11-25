class ApiResult<T> {
  final int code;
  final String message;
  final T? data;

  ApiResult({
    required this.code,
    required this.message,
    this.data,
  });

  factory ApiResult.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResult(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }

  bool get isSuccess => code == 200;
}
