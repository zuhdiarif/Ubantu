import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';

class SendPasswordResetOtpUseCase {
  final IAuthRepository repository;

  SendPasswordResetOtpUseCase(this.repository);

  Future<AppResult<bool>> execute(String email) {
    return repository.sendPasswordResetOtp(email);
  }
}
