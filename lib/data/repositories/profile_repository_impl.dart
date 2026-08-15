import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_profile_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/user_model.dart';
import 'package:ubantu/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final SupabaseProfileService? _supabaseProfileService;

  ProfileRepositoryImpl({SupabaseProfileService? service})
      : _supabaseProfileService = service;

  @override
  Future<AppResult<UserModel>> getProfile(String userId) async {
    final service = _supabaseProfileService;
    if (service != null) {
      final result = await service.getProfile(userId);
      if (result.isSuccess) {
        return result;
      }
    }

    return AppResult.success(UserModel(
      id: userId,
      fullName: 'Mahasiswa UB',
      email: 'mahasiswa@student.ub.ac.id',
      phoneNumber: '081234567890',
      nim: '245150200111001',
      verificationStatus: KtmVerificationStatus.verified,
    ));
  }

  @override
  Future<AppResult<UserModel>> updateProfile(UserModel user) async {
    final service = _supabaseProfileService;
    if (service != null) {
      final result = await service.updateProfile(user);
      if (result.isSuccess) {
        return result;
      }
    }

    return AppResult.success(user);
  }
}
