import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_order_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';

class ServiceOrderRepositoryImpl implements IServiceOrderRepository {
  final SupabaseOrderService _service;

  ServiceOrderRepositoryImpl({SupabaseOrderService? service})
      : _service = service ?? SupabaseOrderService();

  @override
  Future<AppResult<List<ServiceOrderModel>>> getActiveOrders() {
    return _service.getActiveOrders();
  }

  @override
  Future<AppResult<List<ServiceOrderModel>>> getOrderHistory(String userId) {
    return _service.getOrderHistory(userId);
  }

  @override
  Future<AppResult<ServiceOrderModel>> createOrder(ServiceOrderModel order) {
    return _service.createOrder(order);
  }

  @override
  Future<AppResult<ServiceOrderModel>> updateOrderStatus(
    String orderId,
    MoveServiceStatus status,
  ) {
    return _service.updateOrderStatus(orderId, status);
  }

  @override
  Future<AppResult<ServiceOrderModel>> acceptOrder(
    String orderId,
    String helperId,
  ) {
    return _service.acceptOrder(orderId, helperId);
  }
}
