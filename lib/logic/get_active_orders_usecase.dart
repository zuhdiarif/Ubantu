import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/service_order_model.dart';
import 'package:ubantu/data/repositories/service_order_repository.dart';

class GetActiveOrdersUseCase {
  final IServiceOrderRepository _repository;

  GetActiveOrdersUseCase(this._repository);

  Future<AppResult<List<ServiceOrderModel>>> execute() {
    return _repository.getActiveOrders();
  }
}
