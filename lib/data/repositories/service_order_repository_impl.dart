import 'dart:io';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_order_service.dart';
import 'package:ubantu/data/services/supabase_storage_service.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/service_order_model.dart';
import 'package:ubantu/data/repositories/service_order_repository.dart';
import 'package:ubantu/data/repositories/session_scoped.dart';

class ServiceOrderRepositoryImpl implements IServiceOrderRepository, SessionScoped {
  final SupabaseOrderService _service;
  final SupabaseStorageService _storageService;

  bool get hasRemoteService => true;
  SupabaseOrderService get remoteService => _service;

  ServiceOrderRepositoryImpl({
    SupabaseOrderService? service,
    SupabaseStorageService? storageService,
  })  : _service = service ?? SupabaseOrderService(),
        _storageService = storageService ?? SupabaseStorageService();

  @override
  void clearSessionCache() {
    _service.clearSessionCache();
  }

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

  @override
  Stream<ServiceOrderModel?> watchOrder(String orderId) {
    return _service.watchOrder(orderId);
  }

  @override
  Future<AppResult<ServiceOrderModel>> completeOrderWithProof(
    String orderId,
    File photo,
  ) async {
    final uploadResult = await _storageService.uploadCompletionProof(photo, orderId);
    if (!uploadResult.isSuccess || uploadResult.data == null) {
      return AppResult.failure(uploadResult.errorMessage ?? 'Upload bukti foto gagal');
    }
    return _service.completeOrderWithProof(
      orderId,
      uploadResult.data!,
      DateTime.now(),
    );
  }

  @override
  Future<AppResult<ServiceOrderModel>> confirmBarter(String orderId) {
    return _service.confirmBarter(orderId);
  }

  @override
  Future<AppResult<void>> updateOrderNegotiation(
    String orderId, {
    required PaymentMethodType paymentMethod,
    required int price,
    String? barterDescription,
  }) {
    return _service.updateOrderNegotiation(
      orderId,
      paymentMethod: paymentMethod,
      price: price,
      barterDescription: barterDescription,
    );
  }

  @override
  Future<AppResult<ServiceOrderModel>> fetchOrderById(String orderId) {
    return _service.fetchOrderById(orderId);
  }
}
