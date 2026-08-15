import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/reward_points_model.dart';

abstract class ILoyaltyRepository {
  Future<AppResult<RewardPointsModel>> getLoyaltyPoints(String userId);
  Future<AppResult<RewardPointsModel>> claimVoucher(String userId, int pointsRequired);
}
