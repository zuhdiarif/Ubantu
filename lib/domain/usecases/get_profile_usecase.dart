import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/user_model.dart';
import 'package:ubantu/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final IProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<AppResult<UserModel>> execute(String userId) {
    return repository.getProfile(userId);
  }
}
