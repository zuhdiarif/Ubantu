import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/theme/app_colors.dart';
import 'package:ubantu/core/theme/app_theme.dart';
import 'package:ubantu/core/theme/app_typography.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/chat_repository_impl.dart';
import 'package:ubantu/data/services/supabase_auth_service.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/service_order_model.dart';
import 'package:ubantu/data/repositories/service_order_repository.dart';
import 'package:ubantu/ui/aktivitas/service_order_provider.dart';

class MockServiceOrderRepository implements IServiceOrderRepository {
  List<ServiceOrderModel> orders = [];

  @override
  Future<AppResult<ServiceOrderModel>> createOrder(ServiceOrderModel order) async {
    orders.add(order);
    return AppResult.success(order);
  }

  @override
  Future<AppResult<List<ServiceOrderModel>>> getActiveOrders() async {
    return AppResult.success(orders);
  }

  @override
  Future<AppResult<List<ServiceOrderModel>>> getOrderHistory(String userId) async {
    return AppResult.success(orders);
  }

  @override
  Future<AppResult<ServiceOrderModel>> updateOrderStatus(String orderId, MoveServiceStatus status) async {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final updated = orders[idx].copyWith(status: status);
      orders[idx] = updated;
      return AppResult.success(updated);
    }
    return AppResult.failure('Not found');
  }

  @override
  Future<AppResult<ServiceOrderModel>> acceptOrder(String orderId, String helperId) async {
    return updateOrderStatus(orderId, MoveServiceStatus.accepted);
  }

  @override
  Stream<ServiceOrderModel?> watchOrder(String orderId) => const Stream.empty();

  @override
  Future<AppResult<ServiceOrderModel>> completeOrderWithProof(
    String orderId,
    File photo,
  ) async {
    return updateOrderStatus(orderId, MoveServiceStatus.completed);
  }

  @override
  Future<AppResult<ServiceOrderModel>> confirmBarter(
    String orderId,
  ) async {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final updated = orders[idx].copyWith(barterConfirmedByCustomer: true);
      orders[idx] = updated;
      return AppResult.success(updated);
    }
    return AppResult.failure('Not found');
  }

  @override
  Future<AppResult<ServiceOrderModel>> fetchOrderById(String orderId) async {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      return AppResult.success(orders[idx]);
    }
    return AppResult.failure('Not found');
  }

  @override
  Future<AppResult<void>> updateOrderNegotiation(
    String orderId, {
    required PaymentMethodType paymentMethod,
    required int price,
    String? barterDescription,
  }) async {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      orders[idx] = orders[idx].copyWith(
        barterDescription: barterDescription,
      );
      return AppResult.success(null);
    }
    return AppResult.failure('Not found');
  }
}

void main() {
  group('Squad 4 Cleanup & Performance Tests', () {
    test('Theme tokens and light theme render correctly from components/theme', () {
      expect(AppColors.primaryGreen, isNotNull);
      expect(AppColors.background, isNotNull);
      expect(AppTypography.fontFamily, 'Plus Jakarta Sans');

      final theme = AppTheme.lightTheme;
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.primaryGreen);
    });

    test('ChatRepositoryImpl getChatRooms operates cleanly in offline mode', () async {
      final repo = ChatRepositoryImpl();
      final result = await repo.getChatRooms();

      expect(result.isSuccess, true);
      expect(result.data, isEmpty);
    });

    test('ServiceOrderProvider stream subscription lifecycle operates safely', () {
      final repo = MockServiceOrderRepository();
      final provider = ServiceOrderProvider(repository: repo);

      expect(provider.activeOrder, isNull);
      expect(() => provider.subscribeToOrder('order-123'), returnsNormally);
      expect(() => provider.cancelOrderSubscription(), returnsNormally);
      expect(() => provider.dispose(), returnsNormally);
    });

    test('SupabaseAuthService session and cache methods operate without throwing', () async {
      final authService = SupabaseAuthService();
      expect(authService.hasActiveSession(), false);
      expect(authService.getCurrentUser(), isNull);
      await authService.logout();
      expect(authService.getCurrentUser(), isNull);
    });
  });
}
