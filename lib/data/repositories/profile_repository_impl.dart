import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_profile_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/services/supabase_storage_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/user_model.dart';
import 'package:ubantu/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final SupabaseProfileService _remoteService;
  final SupabaseStorageService _storageService;

  ProfileRepositoryImpl({
    SupabaseProfileService? remoteService,
    SupabaseProfileService? service,
    SupabaseStorageService? storageService,
  })  : _remoteService = remoteService ?? service ?? SupabaseProfileService(),
        _storageService = storageService ?? SupabaseStorageService();

  bool get hasRemoteService => true;
  SupabaseProfileService get remoteService => _remoteService;
  SupabaseStorageService get storageService => _storageService;
  bool get isRemoteActive => SupabaseService.instance.isInitialized;
  bool get _useSupabase => isRemoteActive;

  @override
  Future<AppResult<UserModel>> getProfile(String userId) async {
    if (_useSupabase) {
      final result = await _remoteService.getProfile(userId);
      if (result.isSuccess) {
        return result;
      }
    }

    return AppResult.success(UserModel(
      id: userId,
      fullName: 'Mahasiswa UB',
      email: 'mahasiswa@student.ub.ac.id',
      phoneNumber: '',
      nim: '',
      verificationStatus: KtmVerificationStatus.pending,
    ));
  }

  @override
  Future<AppResult<UserModel>> updateProfile(UserModel user) async {
    if (_useSupabase) {
      final result = await _remoteService.updateProfile(user);
      if (result.isSuccess) {
        return result;
      }
    }

    return AppResult.success(user);
  }
}
