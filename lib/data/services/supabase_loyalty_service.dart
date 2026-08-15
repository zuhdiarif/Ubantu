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
          .single();

      return AppResult.success(RewardPointsModel.fromJson(response));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<RewardPointsModel>> claimVoucher(String userId, int pointsRequired) async {
    try {
      final current = await getLoyaltyPoints(userId);
      if (!current.isSuccess || current.data == null) {
        return AppResult.failure('Gagal memuat poin loyalty');
      }

      final points = current.data!;
      if (points.totalPoints < pointsRequired) {
        return AppResult.failure('Poin kamu tidak mencukupi untuk klaim voucher ini');
      }

      final newTotal = points.totalPoints - pointsRequired;
      final newVouchers = points.availableVouchers + 1;
      final newCodes = List<String>.from(points.claimedVoucherCodes)
        ..add('GRATIS1X_${DateTime.now().millisecondsSinceEpoch}');

      final response = await _effectiveClient
          .from('loyalty_points')
          .update({
            'total_points': newTotal,
            'available_vouchers': newVouchers,
            'claimed_voucher_codes': newCodes,
          })
          .eq('user_id', userId)
          .select()
          .single();

      return AppResult.success(RewardPointsModel.fromJson(response));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }
}
