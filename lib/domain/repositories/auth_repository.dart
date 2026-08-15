import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/user_model.dart';

abstract class IAuthRepository {
  Future<AppResult<UserModel>> login(String email, String password);
  Future<AppResult<UserModel>> signUp(String email, String password, Map<String, dynamic> metadata);
  Future<AppResult<bool>> sendOtp(String email);
  Future<AppResult<bool>> verifyOtp(String email, String token);
  Future<void> logout();
  UserModel? getCurrentUser();
  bool didSignUpReturnSession();
}
