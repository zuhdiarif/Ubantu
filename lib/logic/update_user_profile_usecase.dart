import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/user_model.dart';
import 'package:ubantu/data/repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  final IAuthRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<AppResult<UserModel>> execute(UserModel updatedUser) {
    return repository.updateProfile(updatedUser);
  }
}
