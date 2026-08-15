enum ViewStatus { initial, loading, success, error }

class ViewModelState<T> {
  final ViewStatus status;
  final T? data;
  final String? message;

  const ViewModelState._({
    required this.status,
    this.data,
    this.message,
  });

  factory ViewModelState.initial() {
    return const ViewModelState._(status: ViewStatus.initial);
  }

  factory ViewModelState.loading() {
    return const ViewModelState._(status: ViewStatus.loading);
  }

  factory ViewModelState.success(T data) {
    return ViewModelState._(status: ViewStatus.success, data: data);
  }

  factory ViewModelState.error(String message) {
    return ViewModelState._(status: ViewStatus.error, message: message);
  }

  bool get isInitial => status == ViewStatus.initial;
  bool get isLoading => status == ViewStatus.loading;
  bool get isSuccess => status == ViewStatus.success;
  bool get isError => status == ViewStatus.error;
}
