import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final IAuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<AppResult<bool>> execute() {
    return repository.signInWithGoogle();
  }
}
