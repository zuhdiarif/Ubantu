import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/auth_repository.dart';

class SendOtpUseCase {
  final IAuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<AppResult<bool>> execute(String email) {
    return repository.sendOtp(email);
  }
}
