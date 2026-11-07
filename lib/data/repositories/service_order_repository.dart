import 'dart:io';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/service_order_model.dart';

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
  Stream<ServiceOrderModel?> watchOrder(String orderId);
  Future<AppResult<ServiceOrderModel>> completeOrderWithProof(
    String orderId,
    File photo,
  );
  Future<AppResult<ServiceOrderModel>> confirmBarter(
    String orderId,
  );
  Future<AppResult<void>> updateOrderNegotiation(
    String orderId, {
    required PaymentMethodType paymentMethod,
    required int price,
    String? barterDescription,
  });
  Future<AppResult<ServiceOrderModel>> fetchOrderById(String orderId);
}
