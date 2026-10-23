import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';

abstract class IServiceOrderRepository {
  Future<AppResult<List<ServiceOrderModel>>> getActiveOrders();
  Future<AppResult<List<ServiceOrderModel>>> getOrderHistory(String userId);
  Future<AppResult<ServiceOrderModel>> createOrder(ServiceOrderModel order);
  Future<AppResult<ServiceOrderModel>> updateOrderStatus(
    String orderId,
    MoveServiceStatus status,
  );
  Future<AppResult<ServiceOrderModel>> acceptOrder(
    String orderId,
    String helperId,
  );
}
