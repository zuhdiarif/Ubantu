import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/mitra_repository.dart';

class AcceptMitraOrderUseCase {
  final IMitraRepository _repository;

  AcceptMitraOrderUseCase(this._repository);

  Future<AppResult<bool>> execute(String orderId) {
    return _repository.acceptOrder(orderId);
  }
}
