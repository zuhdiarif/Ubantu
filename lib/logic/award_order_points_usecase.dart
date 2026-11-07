import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/reward_points_model.dart';
import 'package:ubantu/data/repositories/loyalty_repository.dart';

class AwardOrderPointsUseCase {
  final ILoyaltyRepository repository;

  AwardOrderPointsUseCase(this.repository);

  Future<AppResult<RewardPointsModel>> execute(String userId, String orderId) {
    return repository.awardOrderPoints(userId, orderId);
  }
}
