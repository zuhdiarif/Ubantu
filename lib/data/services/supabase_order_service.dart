import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';

class SupabaseOrderService {
  static const String _table = 'service_orders';

  Future<AppResult<List<ServiceOrderModel>>> getActiveOrders() async {
    try {
      final response = await SupabaseService.instance.client
          .from(_table)
          .select()
          .eq('status', MoveServiceStatus.waiting.name)
          .order('created_at', ascending: false);

      final orders = response
          .map((e) => ServiceOrderModel.fromJson(e))
          .toList();
      return AppResult.success(orders);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<List<ServiceOrderModel>>> getOrderHistory(
    String userId,
  ) async {
    try {
      final response = await SupabaseService.instance.client
          .from(_table)
          .select()
          .or('requester_id.eq.$userId,helper_id.eq.$userId')
          .order('created_at', ascending: false);

      final orders = response
          .map((e) => ServiceOrderModel.fromJson(e))
          .toList();
      return AppResult.success(orders);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<ServiceOrderModel>> createOrder(
    ServiceOrderModel order,
  ) async {
    try {
      final data = order.toJson()..remove('id');
      final response = await SupabaseService.instance.client
          .from(_table)
          .insert(data)
          .select()
          .single();

      return AppResult.success(
        ServiceOrderModel.fromJson(response),
      );
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<ServiceOrderModel>> updateOrderStatus(
    String orderId,
    MoveServiceStatus status,
  ) async {
    try {
      final response = await SupabaseService.instance.client
          .from(_table)
          .update({'status': status.name})
          .eq('id', orderId)
          .select()
          .single();

      return AppResult.success(
        ServiceOrderModel.fromJson(response),
      );
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<ServiceOrderModel>> acceptOrder(
    String orderId,
    String helperId,
  ) async {
    try {
      final response = await SupabaseService.instance.client
          .from(_table)
          .update({
            'helper_id': helperId,
            'status': MoveServiceStatus.accepted.name,
          })
          .eq('id', orderId)
          .select()
          .single();

      return AppResult.success(
        ServiceOrderModel.fromJson(response),
      );
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }
}
