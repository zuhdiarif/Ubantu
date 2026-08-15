import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/user_model.dart';
import 'package:ubantu/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final IProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<AppResult<UserModel>> execute(UserModel user) {
    return repository.updateProfile(user);
  }
}
