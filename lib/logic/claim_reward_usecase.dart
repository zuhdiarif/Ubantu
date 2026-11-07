import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/reward_points_model.dart';
import 'package:ubantu/data/repositories/loyalty_repository.dart';

class ClaimRewardUseCase {
  final ILoyaltyRepository repository;

  ClaimRewardUseCase(this.repository);

  Future<AppResult<RewardPointsModel>> execute(String userId, int pointsRequired) {
    return repository.claimVoucher(userId, pointsRequired);
  }
}
