import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/reward_points_model.dart';

class SupabaseLoyaltyService {
  final SupabaseClient? _client;

  SupabaseLoyaltyService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  Future<AppResult<RewardPointsModel>> getLoyaltyPoints(String userId) async {
    try {
      final response = await _effectiveClient
          .from('loyalty_points')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return AppResult.success(RewardPointsModel(userId: userId));
      }

      return AppResult.success(RewardPointsModel.fromJson(response));
    } on PostgrestException catch (e) {
      return AppResult.failure(_mapPostgrestError(e.message));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('insufficient_points') || msg.contains('order_not_eligible')) {
        return AppResult.failure(_mapPostgrestError(msg));
      }
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<RewardPointsModel>> claimVoucher([String? userId, int? pointsRequired]) async {
    try {
      final response = await _effectiveClient.rpc('claim_loyalty_voucher');
      return AppResult.success(_parseRpcResult(response));
    } on PostgrestException catch (e) {
      return AppResult.failure(_mapPostgrestError(e.message));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('insufficient_points') || msg.contains('order_not_eligible')) {
        return AppResult.failure(_mapPostgrestError(msg));
      }
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<RewardPointsModel>> awardOrderPoints(String orderId) async {
    try {
      final response = await _effectiveClient.rpc(
        'award_order_points',
        params: {'p_order_id': orderId},
      );
      return AppResult.success(_parseRpcResult(response));
    } on PostgrestException catch (e) {
      return AppResult.failure(_mapPostgrestError(e.message));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('insufficient_points') || msg.contains('order_not_eligible')) {
        return AppResult.failure(_mapPostgrestError(msg));
      }
      return AppResult.failure(e.toString());
    }
  }

  RewardPointsModel _parseRpcResult(dynamic data) {
    if (data is Map<String, dynamic>) {
      return RewardPointsModel.fromJson(data);
    }
    if (data is Map) {
      return RewardPointsModel.fromJson(Map<String, dynamic>.from(data));
    }
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map<String, dynamic>) {
        return RewardPointsModel.fromJson(first);
      }
      if (first is Map) {
        return RewardPointsModel.fromJson(Map<String, dynamic>.from(first));
      }
    }
    return const RewardPointsModel(userId: '');
  }

  String _mapPostgrestError(String message) {
    if (message.contains('insufficient_points')) {
      return 'Poin kamu tidak mencukupi untuk klaim voucher ini';
    }
    if (message.contains('order_not_eligible')) {
      return 'Pesanan belum selesai atau bukan milik kamu';
    }
    return 'Gagal memproses poin. Silakan coba lagi.';
  }
}
