import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/auth_repository.dart';

class ResendSignupOtpUseCase {
  final IAuthRepository repository;

  ResendSignupOtpUseCase(this.repository);

  Future<AppResult<bool>> execute(String email) {
    return repository.resendSignupOtp(email);
  }
}
