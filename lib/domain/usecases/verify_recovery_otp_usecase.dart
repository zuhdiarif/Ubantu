import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';

class VerifyRecoveryOtpUseCase {
  final IAuthRepository repository;

  VerifyRecoveryOtpUseCase(this.repository);

  Future<AppResult<bool>> execute(String email, String token) {
    return repository.verifyRecoveryOtp(email, token);
  }
}
