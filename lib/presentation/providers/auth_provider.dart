import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/data/services/supabase_auth_service.dart';
import 'package:ubantu/data/services/supabase_profile_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/services/supabase_storage_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/user_model.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';
import 'package:ubantu/domain/usecases/login_usecase.dart';
import 'package:ubantu/domain/usecases/sign_in_with_google_usecase.dart';

import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/domain/repositories/notification_repository.dart';

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
         repository ?? AuthRepositoryImpl(),
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

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  void _initAuthListener() {
    if (SupabaseService.instance.isInitialized) {
      _authSubscription =
          SupabaseService.instance.client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          _currentUser = _repository.getCurrentUser();
          AppAuthNotifier.instance.setLoggedIn(true);
          _syncProfileWithRemote();
        } else if (data.event == AuthChangeEvent.signedOut) {
          _currentUser = null;
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
    String? fullName,
    String? phoneNumber,
    UserGender? gender,
    bool? isFemaleOnlyPreferred,
  }) async {
    final baseUser = _currentUser ?? const UserModel(
      id: 'usr_current',
      fullName: 'Ahmad Farel',
      email: 'farel@student.ub.ac.id',
      phoneNumber: '081234567890',
      nim: '',
    );

    final updated = baseUser.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      gender: gender,
      isFemaleOnlyPreferred: isFemaleOnlyPreferred,
    );

    _currentUser = updated;
    final repo = _repository;
    if (repo is AuthRepositoryImpl) {
      repo.setCurrentUser(updated);
    }

    try {
      if (SupabaseService.instance.isInitialized) {
        await SupabaseAuthService().updateUserMetadata({
          if (updated.fullName.isNotEmpty) 'full_name': updated.fullName,
          if (updated.phoneNumber.isNotEmpty) 'phone_number': updated.phoneNumber,
          'gender': updated.gender.name,
          'is_female_only_preferred': updated.isFemaleOnlyPreferred,
        });
        await SupabaseProfileService().updateProfile(updated);
      }
    } catch (_) {}

    notifyListeners();
    return AppResult.success(updated);
  }

  Future<AppResult<String>> updateAvatar(File imageFile) async {
    _isLoading = true;
    notifyListeners();

    final userId = _currentUser?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final uploadResult = await SupabaseStorageService().uploadAvatar(imageFile, userId);

    _isLoading = false;

    if (uploadResult.isSuccess && uploadResult.data != null) {
      final avatarUrl = uploadResult.data!;
      final baseUser = _currentUser ?? const UserModel(
        id: 'usr_current',
        fullName: 'Ahmad Farel',
        email: 'farel@student.ub.ac.id',
        phoneNumber: '081234567890',
        nim: '',
      );
      final updated = baseUser.copyWith(avatarUrl: avatarUrl);
      _currentUser = updated;

      final repo = _repository;
      if (repo is AuthRepositoryImpl) {
        repo.setCurrentUser(updated);
      }

      try {
        if (SupabaseService.instance.isInitialized) {
          await SupabaseAuthService().updateUserMetadata({'avatar_url': avatarUrl});
          await SupabaseProfileService().updateProfile(updated);
        }
      } catch (_) {}

      notifyListeners();
      return AppResult.success(avatarUrl);
    } else {
      notifyListeners();
      return uploadResult;
    }
  }

  Future<AppResult<String>> submitKtm({required String nim, required File photoFile}) async {
    _isLoading = true;
    notifyListeners();

    final userId = _currentUser?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final uploadResult = await SupabaseStorageService().uploadKtmPhoto(photoFile, userId);

    _isLoading = false;

    if (uploadResult.isSuccess && uploadResult.data != null) {
      final ktmUrl = uploadResult.data!;
      final baseUser = _currentUser ?? const UserModel(
        id: 'usr_current',
        fullName: 'Ahmad Farel',
        email: 'farel@student.ub.ac.id',
        phoneNumber: '081234567890',
        nim: '',
      );
      final updated = baseUser.copyWith(
        nim: nim,
        ktmPhotoUrl: ktmUrl,
        verificationStatus: KtmVerificationStatus.pending,
      );
      _currentUser = updated;

      final repo = _repository;
      if (repo is AuthRepositoryImpl) {
        repo.setCurrentUser(updated);
      }

      try {
        if (SupabaseService.instance.isInitialized) {
          await SupabaseAuthService().updateUserMetadata({
            'nim': nim,
            'ktm_photo_url': ktmUrl,
            'verification_status': KtmVerificationStatus.pending.name,
          });
          await SupabaseProfileService().updateProfile(updated);
        }
      } catch (_) {}

      notifyListeners();
      return AppResult.success(ktmUrl);
    } else {
      notifyListeners();
      return uploadResult;
    }
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
    notifyListeners();

    final result = await _signInWithGoogleUseCase.execute();
    _isLoading = false;

    if (result.isSuccess) {
      _currentUser = _repository.getCurrentUser();
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

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    _errorMessage = null;
    AppAuthNotifier.instance.setLoggedIn(false);
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
