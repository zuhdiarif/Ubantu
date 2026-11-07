import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/auth_repository.dart';

class UpdatePasswordUseCase {
  final IAuthRepository repository;

  UpdatePasswordUseCase(this.repository);

  Future<AppResult<bool>> execute(String newPassword) {
    return repository.updatePassword(newPassword);
  }
}
