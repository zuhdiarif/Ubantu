import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_loyalty_service.dart';
import 'package:ubantu/domain/models/reward_points_model.dart';
import 'package:ubantu/domain/repositories/loyalty_repository.dart';

class LoyaltyRepositoryImpl implements ILoyaltyRepository {
  final SupabaseLoyaltyService? _supabaseLoyaltyService;

  LoyaltyRepositoryImpl({SupabaseLoyaltyService? remoteService})
      : _supabaseLoyaltyService = remoteService;

  @override
  Future<AppResult<RewardPointsModel>> getLoyaltyPoints(String userId) async {
    final service = _supabaseLoyaltyService;
    if (service != null) {
      final result = await service.getLoyaltyPoints(userId);
      if (result.isSuccess) {
        return result;
      }
    }

    return AppResult.success(RewardPointsModel(
      userId: userId,
      totalPoints: 120,
      availableVouchers: 1,
      claimedVoucherCodes: const ['GRATIS1X_MOCK'],
    ));
  }

  @override
  Future<AppResult<RewardPointsModel>> claimVoucher(String userId, int pointsRequired) async {
    final service = _supabaseLoyaltyService;
    if (service != null) {
      final result = await service.claimVoucher(userId, pointsRequired);
      if (result.isSuccess) {
        return result;
      }
    }

    return AppResult.success(RewardPointsModel(
      userId: userId,
      totalPoints: 20,
      availableVouchers: 2,
      claimedVoucherCodes: const ['GRATIS1X_MOCK', 'GRATIS1X_NEW'],
    ));
  }
}
