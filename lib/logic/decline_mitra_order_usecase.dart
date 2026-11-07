import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/mitra_repository.dart';

class DeclineMitraOrderUseCase {
  final IMitraRepository _repository;

  DeclineMitraOrderUseCase(this._repository);

  Future<AppResult<bool>> execute(String orderId) {
    return _repository.declineOrder(orderId);
  }
}
