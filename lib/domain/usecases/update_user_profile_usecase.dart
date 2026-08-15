import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/user_model.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  final IAuthRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<AppResult<UserModel>> execute(UserModel updatedUser) async {
    return AppResult.success(updatedUser);
  }
}
