import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_exceptions.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/data/services/supabase_auth_service.dart';
import 'package:ubantu/data/services/supabase_profile_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/services/supabase_storage_service.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/user_model.dart';
import 'package:ubantu/data/repositories/auth_repository.dart';
import 'package:ubantu/logic/login_usecase.dart';
import 'package:ubantu/logic/sign_in_with_google_usecase.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/data/repositories/notification_repository.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final IAuthRepository _repository;
  final INotificationRepository _notificationRepository;
  StreamSubscription<AuthState>? _authSubscription;
  KtmVerificationStatus? _previousKtmStatus;

  AuthProvider({
    IAuthRepository? repository,
    INotificationRepository? notificationRepository,
  }) : this._internal(
         repository ?? ServiceLocator.instance.authRepository,
         notificationRepository ?? ServiceLocator.instance.notificationRepository,
       );

  AuthProvider._internal(
    IAuthRepository repository,
    INotificationRepository notificationRepository,
  )   : _repository = repository,
        _notificationRepository = notificationRepository,
        _loginUseCase = LoginUseCase(repository),
        _signInWithGoogleUseCase = SignInWithGoogleUseCase(repository) {
    _currentUser = _repository.getCurrentUser();
    _previousKtmStatus = _currentUser?.verificationStatus;
    if (_currentUser != null) {
      AppAuthNotifier.instance.initLoggedIn(true);
    }
    _initAuthListener();
  }

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  IAuthRepository get repository => _repository;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  UserModel _getBaseUser() {
    if (_currentUser != null) return _currentUser!;
    if (SupabaseService.instance.isInitialized) {
      final sessionUser = SupabaseService.instance.client.auth.currentUser;
      if (sessionUser != null) {
        final meta = sessionUser.userMetadata ?? {};
        return UserModel(
          id: sessionUser.id,
          fullName: meta['full_name'] as String? ?? sessionUser.email?.split('@').first ?? '',
          email: sessionUser.email ?? '',
          phoneNumber: sessionUser.phone ?? (meta['phone_number'] as String? ?? ''),
          nim: meta['nim'] as String? ?? '',
          faculty: meta['faculty'] as String?,
          bio: meta['bio'] as String?,
        );
      }
    }
    return const UserModel(
      id: 'usr_current',
      fullName: '',
      email: '',
      phoneNumber: '',
      nim: '',
    );
  }

  void _initAuthListener() {
    if (SupabaseService.instance.isInitialized) {
      _authSubscription =
          SupabaseService.instance.client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          _currentUser = _repository.getCurrentUser();
          AppAuthNotifier.instance.setOAuthCallbackPending(false);
          AppAuthNotifier.instance.setLoggedIn(true);
          _syncProfileWithRemote();
        } else if (data.event == AuthChangeEvent.signedOut) {
          _currentUser = null;
          AppAuthNotifier.instance.setOAuthCallbackPending(false);
          AppAuthNotifier.instance.setLoggedIn(false);
        }
        notifyListeners();
      });
    }
  }

  void _checkKtmVerificationTransition(KtmVerificationStatus newStatus) {
    if (_previousKtmStatus == KtmVerificationStatus.pending &&
        newStatus == KtmVerificationStatus.verified) {
      _notificationRepository.addNotification(
        'Verifikasi KTM Berhasil!',
        'Selamat! Identitas KTM Universitas Brawijaya kamu telah terverifikasi. Nikmati fitur penuh UBantu!',
        type: 'ktm',
      );
    }
    _previousKtmStatus = newStatus;
  }

  void setKtmVerificationStatus(KtmVerificationStatus status) {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(verificationStatus: status);
    updateUser(updated);
  }

  void updateUser(UserModel updatedUser) {
    final oldStatus = _currentUser?.verificationStatus;
    _currentUser = updatedUser;
    final repo = _repository;
    if (repo is AuthRepositoryImpl) {
      repo.setCurrentUser(updatedUser);
    }
    if (oldStatus != null) {
      _previousKtmStatus = oldStatus;
    }
    _checkKtmVerificationTransition(updatedUser.verificationStatus);
    notifyListeners();
  }

  Future<AppResult<UserModel>> updateProfile({
    UserModel? updatedUser,
    UserModel? user,
    String? fullName,
    String? phoneNumber,
    UserGender? gender,
    bool? isFemaleOnlyPreferred,
    String? faculty,
    String? bio,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final baseUser = updatedUser ?? user ?? _getBaseUser().copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      gender: gender,
      isFemaleOnlyPreferred: isFemaleOnlyPreferred,
      faculty: faculty,
      bio: bio,
    );

    if (SupabaseService.instance.isInitialized) {
      try {
        final profileResult = await SupabaseProfileService().updateProfile(baseUser);
        if (!profileResult.isSuccess) {
          _isLoading = false;
          notifyListeners();
          return AppResult.failure(NetworkException('Gagal memperbarui profil: ${profileResult.errorMessage}').message);
        }
        await SupabaseAuthService().updateUserMetadata({
          if (baseUser.fullName.isNotEmpty) 'full_name': baseUser.fullName,
          if (baseUser.phoneNumber.isNotEmpty) 'phone_number': baseUser.phoneNumber,
          'gender': baseUser.gender.name,
          'is_female_only_preferred': baseUser.isFemaleOnlyPreferred,
          if (baseUser.faculty != null) 'faculty': baseUser.faculty,
          if (baseUser.bio != null) 'bio': baseUser.bio,
        });
      } catch (e) {
        _isLoading = false;
        notifyListeners();
        return AppResult.failure(NetworkException('Gagal memperbarui profil: $e').message);
      }
    }

    _currentUser = baseUser;
    final repo = _repository;
    if (repo is AuthRepositoryImpl) {
      repo.setCurrentUser(baseUser);
    }
    _checkKtmVerificationTransition(baseUser.verificationStatus);
    _isLoading = false;
    notifyListeners();
    return AppResult.success(baseUser);
  }

  Future<AppResult<String>> updateAvatar(dynamic imageFileOrPath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final File imageFile = imageFileOrPath is File ? imageFileOrPath : File(imageFileOrPath.toString());
    final userId = _currentUser?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';

    if (SupabaseService.instance.isInitialized) {
      final uploadResult = await SupabaseStorageService().uploadAvatar(imageFile, userId);
      if (!uploadResult.isSuccess || uploadResult.data == null) {
        _isLoading = false;
        notifyListeners();
        return AppResult.failure(
          uploadResult.errorMessage ?? const ServerException('Gagal mengunggah foto profil.').message,
        );
      }

      final avatarUrl = uploadResult.data!;
      final baseUser = _getBaseUser();
      final updated = baseUser.copyWith(avatarUrl: avatarUrl);

      try {
        final profileRes = await SupabaseProfileService().updateProfile(updated);
        if (!profileRes.isSuccess) {
          _isLoading = false;
          notifyListeners();
          return AppResult.failure(
            NetworkException('Gagal memperbarui foto profil: ${profileRes.errorMessage}').message,
          );
        }
        await SupabaseAuthService().updateUserMetadata({'avatar_url': avatarUrl});
      } catch (e) {
        _isLoading = false;
        notifyListeners();
        return AppResult.failure(
          NetworkException('Gagal memperbarui foto profil: $e').message,
        );
      }

      _currentUser = updated;
      final repo = _repository;
      if (repo is AuthRepositoryImpl) {
        repo.setCurrentUser(updated);
      }
      _isLoading = false;
      notifyListeners();
      return AppResult.success(avatarUrl);
    }

    final avatarUrl = 'https://mock.storage/avatar_$userId.jpg';
    final baseUser = _getBaseUser();
    final updated = baseUser.copyWith(avatarUrl: avatarUrl);
    _currentUser = updated;
    final repo = _repository;
    if (repo is AuthRepositoryImpl) {
      repo.setCurrentUser(updated);
    }
    _isLoading = false;
    notifyListeners();
    return AppResult.success(avatarUrl);
  }

  Future<AppResult<String>> submitKtm({
    required String nim,
    dynamic photoFile,
    String? ktmPath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final String path = ktmPath ?? (photoFile is File ? photoFile.path : (photoFile?.toString() ?? ''));
    final File effectiveFile = photoFile is File ? photoFile : File(path);
    final userId = _currentUser?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';

    if (SupabaseService.instance.isInitialized && _currentUser != null && path.isNotEmpty) {
      final uploadResult = await SupabaseStorageService().uploadKtmPhoto(effectiveFile, userId);
      if (!uploadResult.isSuccess || uploadResult.data == null) {
        _isLoading = false;
        notifyListeners();
        return AppResult.failure(
          uploadResult.errorMessage ?? const ServerException('Gagal mengunggah foto KTM.').message,
        );
      }

      final ktmUrl = uploadResult.data!;
      final baseUser = _getBaseUser();
      final updated = baseUser.copyWith(
        nim: nim,
        ktmPhotoUrl: ktmUrl,
        verificationStatus: KtmVerificationStatus.pending,
      );

      try {
        final profileResult = await SupabaseProfileService().updateProfile(updated);
        if (!profileResult.isSuccess) {
          _isLoading = false;
          notifyListeners();
          return AppResult.failure(
            NetworkException('Gagal menyimpan data verifikasi KTM: ${profileResult.errorMessage}').message,
          );
        }
        await SupabaseAuthService().updateUserMetadata({
          'nim': nim,
          'ktm_photo_url': ktmUrl,
          'verification_status': KtmVerificationStatus.pending.name,
        });
      } catch (e) {
        _isLoading = false;
        notifyListeners();
        return AppResult.failure(
          NetworkException('Gagal menyimpan data verifikasi KTM: $e').message,
        );
      }

      _currentUser = updated;
      final repo = _repository;
      if (repo is AuthRepositoryImpl) {
        repo.setCurrentUser(updated);
      }
      _checkKtmVerificationTransition(updated.verificationStatus);
      _isLoading = false;
      notifyListeners();
      return AppResult.success(ktmUrl);
    }

    final mockUrl = 'https://mock.storage/ktm_$userId.jpg';
    final baseUser = _getBaseUser();
    final updated = baseUser.copyWith(
      nim: nim,
      ktmPhotoUrl: mockUrl,
      verificationStatus: KtmVerificationStatus.pending,
    );
    _currentUser = updated;
    final repo = _repository;
    if (repo is AuthRepositoryImpl) {
      repo.setCurrentUser(updated);
    }
    _checkKtmVerificationTransition(updated.verificationStatus);
    _isLoading = false;
    notifyListeners();
    return AppResult.success(mockUrl);
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _loginUseCase.execute(email, password);
    _isLoading = false;

    if (result.isSuccess) {
      _currentUser = result.data;
      AppAuthNotifier.instance.setLoggedIn(true);
      await _syncProfileWithRemote();
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<void> _syncProfileWithRemote() async {
    if (!SupabaseService.instance.isInitialized) return;
    final user = _repository.getCurrentUser() ?? _currentUser;
    if (user == null) return;

    try {
      final result = await SupabaseProfileService().ensureProfileExists(user);
      if (result.isSuccess && result.data != null) {
        final oldStatus = _currentUser?.verificationStatus;
        _currentUser = result.data;
        final repo = _repository;
        if (repo is AuthRepositoryImpl) {
          repo.setCurrentUser(result.data!);
        }
        if (oldStatus != null) {
          _previousKtmStatus = oldStatus;
        }
        _checkKtmVerificationTransition(result.data!.verificationStatus);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    AppAuthNotifier.instance.setOAuthCallbackPending(true);
    notifyListeners();
    final result = await _signInWithGoogleUseCase.execute();
    _isLoading = false;

    if (result.isSuccess) {
      _currentUser = _repository.getCurrentUser();
      AppAuthNotifier.instance.setOAuthCallbackPending(false);
      AppAuthNotifier.instance.setLoggedIn(true);
      await _syncProfileWithRemote();
      notifyListeners();
      return true;
    } else {
      AppAuthNotifier.instance.setOAuthCallbackPending(false);
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshProfile() async {
    final user = _currentUser ?? _repository.getCurrentUser();
    if (user == null) return;
    if (SupabaseService.instance.isInitialized) {
      try {
        final result = await SupabaseProfileService().getProfile(user.id);
        if (result.isSuccess && result.data != null) {
          final oldStatus = _currentUser?.verificationStatus;
          _currentUser = result.data;
          final repo = _repository;
          if (repo is AuthRepositoryImpl) {
            repo.setCurrentUser(result.data!);
          }
          if (oldStatus != null) {
            _previousKtmStatus = oldStatus;
          }
          _checkKtmVerificationTransition(result.data!.verificationStatus);
          notifyListeners();
          return;
        } else {
          await _syncProfileWithRemote();
          return;
        }
      } catch (_) {}

      final authUser = _repository.getCurrentUser();
      if (authUser != null) {
        _currentUser = authUser;
        notifyListeners();
      }
    }
  }

  Future<AppResult<bool>> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.deleteAccount();
    _isLoading = false;

    if (result.isSuccess) {
      _currentUser = null;
      _errorMessage = null;
      SessionManager.instance.clearAll();
      notifyListeners();
      return AppResult.success(true);
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return result;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } finally {
      _currentUser = null;
      _errorMessage = null;

      AppAuthNotifier.instance.setOAuthCallbackPending(false);
      AppAuthNotifier.instance.setLoggedIn(false);
      ServiceLocator.instance.clearSessionCaches();
      notifyListeners();
    }
  }

  void resetSession() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

class SessionManager {
  static final SessionManager instance = SessionManager._();
  SessionManager._();
  void clearAll() {
    ServiceLocator.instance.clearSessionCaches();
    AppAuthNotifier.instance.setLoggedIn(false);
    AppAuthNotifier.instance.setOAuthCallbackPending(false);
  }
}
