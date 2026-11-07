import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/user_model.dart';
import 'package:ubantu/data/repositories/auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<AppResult<UserModel>> execute(String email, String password) {
    return repository.login(email, password);
  }
}
