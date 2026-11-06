import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/reward_points_model.dart';
import 'package:ubantu/domain/repositories/loyalty_repository.dart';

class AddPointsUseCase {
  final ILoyaltyRepository repository;

  AddPointsUseCase(this.repository);

  Future<AppResult<RewardPointsModel>> execute(String userId, int pointsToAdd) {
    return repository.addPoints(userId, pointsToAdd);
  }
}
