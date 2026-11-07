import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/repositories/mitra_repository.dart';

class UpdateMitraOrderStatusUseCase {
  final IMitraRepository _repository;

  UpdateMitraOrderStatusUseCase(this._repository);

  Future<AppResult<bool>> execute(String orderId, MoveServiceStatus status) {
    return _repository.updateOrderStatus(orderId, status);
  }
}
