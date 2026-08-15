import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/user_model.dart';

abstract class IProfileRepository {
  Future<AppResult<UserModel>> getProfile(String userId);
  Future<AppResult<UserModel>> updateProfile(UserModel user);
}
