import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';

class CreateServiceOrderUseCase {
  final IServiceOrderRepository _repository;

  CreateServiceOrderUseCase(this._repository);

  Future<AppResult<ServiceOrderModel>> execute(ServiceOrderModel order) {
    return _repository.createOrder(order);
  }
}
