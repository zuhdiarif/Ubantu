import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_profile_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/services/supabase_storage_service.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/user_model.dart';
import 'package:ubantu/data/repositories/profile_repository.dart';
import 'package:ubantu/data/repositories/session_scoped.dart';

class ProfileRepositoryImpl implements IProfileRepository, SessionScoped {
  final SupabaseProfileService _remoteService;
  final SupabaseStorageService _storageService;
  UserModel? _cachedUser;

  ProfileRepositoryImpl({
    SupabaseProfileService? remoteService,
    SupabaseProfileService? service,
    SupabaseStorageService? storageService,
  })  : _remoteService = remoteService ?? service ?? SupabaseProfileService(),
        _storageService = storageService ?? SupabaseStorageService();

  @override
  void clearSessionCache() {
    _cachedUser = null;
  }

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
        _cachedUser = result.data;
      }
      return result;
    }

    return AppResult.success(_cachedUser ?? UserModel(
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
        _cachedUser = result.data;
      }
      return result;
    }

    _cachedUser = user;
    return AppResult.success(user);
  }

  Future<AppResult<String>> uploadKtmImage(dynamic fileOrPath, [String? userId]) async {
    if (_useSupabase) {
      final user = _cachedUser;
      final uid = userId ?? user?.id ?? 'usr_current';
      return await _storageService.uploadKtmPhoto(fileOrPath, uid);
    }
    return AppResult.success('https://mock.storage/ktm_mock.jpg');
  }
}
