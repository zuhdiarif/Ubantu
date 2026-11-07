import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final IAuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<AppResult<bool>> execute(String email, String token) {
    return repository.verifyOtp(email, token);
  }
}
