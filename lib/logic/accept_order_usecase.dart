import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/service_order_model.dart';
import 'package:ubantu/data/repositories/service_order_repository.dart';

class AcceptOrderUseCase {
  final IServiceOrderRepository _repository;

  AcceptOrderUseCase(this._repository);

  Future<AppResult<ServiceOrderModel>> execute(
    String orderId,
    String helperId,
  ) {
    return _repository.acceptOrder(orderId, helperId);
  }
}
