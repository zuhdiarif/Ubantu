import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/mitra_repository.dart';

class GetIncomingOrdersUseCase {
  final IMitraRepository _repository;

  GetIncomingOrdersUseCase(this._repository);

  Future<AppResult<List<ServiceOrderModel>>> execute() {
    return _repository.getIncomingOrders();
  }
}
