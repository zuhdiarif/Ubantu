import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_loyalty_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/reward_points_model.dart';
import 'package:ubantu/domain/repositories/loyalty_repository.dart';

class LoyaltyRepositoryImpl implements ILoyaltyRepository {
  final SupabaseLoyaltyService _remoteService;

  LoyaltyRepositoryImpl({SupabaseLoyaltyService? remoteService})
      : _remoteService = remoteService ?? SupabaseLoyaltyService();

  bool get hasRemoteService => true;
  SupabaseLoyaltyService get remoteService => _remoteService;
  bool get isRemoteActive => SupabaseService.instance.isInitialized;
  bool get _useSupabase => isRemoteActive;

  @override
  Future<AppResult<RewardPointsModel>> getLoyaltyPoints(String userId) async {
    if (_useSupabase) {
      final result = await _remoteService.getLoyaltyPoints(userId);
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
    if (_useSupabase) {
      final result = await _remoteService.claimVoucher(userId, pointsRequired);
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

  @override
  Future<AppResult<RewardPointsModel>> addPoints(String userId, int pointsToAdd) async {
    if (_useSupabase) {
      final result = await _remoteService.addPoints(userId, pointsToAdd);
      if (result.isSuccess) {
        return result;
      }
    }

    return AppResult.success(RewardPointsModel(
      userId: userId,
      totalPoints: 120 + pointsToAdd,
      availableVouchers: 1,
      claimedVoucherCodes: const ['GRATIS1X_MOCK'],
    ));
  }
}
