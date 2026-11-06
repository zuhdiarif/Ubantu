class AppResult<T> {
  final T? data;
  final String? errorMessage;
  final String? errorCode;
  final bool isSuccess;

  const AppResult._({this.data, this.errorMessage, this.errorCode, required this.isSuccess});

  factory AppResult.success(T data) {
    return AppResult._(data: data, isSuccess: true);
  }

  factory AppResult.failure(String errorMessage, {String? errorCode}) {
    return AppResult._(errorMessage: errorMessage, errorCode: errorCode, isSuccess: false);
  }
}
