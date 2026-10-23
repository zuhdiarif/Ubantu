import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';

class UpdateOrderStatusUseCase {
  final IServiceOrderRepository _repository;

  UpdateOrderStatusUseCase(this._repository);

  Future<AppResult<ServiceOrderModel>> execute(
    String orderId,
    MoveServiceStatus status,
  ) {
    return _repository.updateOrderStatus(orderId, status);
  }
}
