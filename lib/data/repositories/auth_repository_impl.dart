import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_auth_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/user_model.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final SupabaseAuthService _authService;
  UserModel? _currentUser;
  bool _signUpReturnedSession = false;

  AuthRepositoryImpl({SupabaseAuthService? service})
      : _authService = service ?? SupabaseAuthService();

  @override
  Future<AppResult<UserModel>> login(String email, String password) async {
    if (_authService.isAvailable) {
      final result = await _authService.login(email, password);
      if (result.isSuccess) {
        _currentUser = result.data;
      }
      return result;
    }

    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = UserModel(
      id: 'usr_mock',
      fullName: 'Mock User',
      email: email,
      phoneNumber: '081234567890',
      nim: '245150200111001',
      verificationStatus: KtmVerificationStatus.verified,
    );
    return AppResult.success(_currentUser!);
  }

  @override
  Future<AppResult<UserModel>> signUp(
    String email,
    String password,
    Map<String, dynamic> metadata,
  ) async {
    if (_authService.isAvailable) {
      final result = await _authService.signUp(email, password, metadata);
      if (result.isSuccess) {
        _currentUser = result.data;
        _signUpReturnedSession = _authService.hasActiveSession();
      }
      return result;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    _signUpReturnedSession = false;
    _currentUser = UserModel(
      id: 'usr_new_${DateTime.now().millisecondsSinceEpoch}',
      fullName: metadata['full_name'] as String? ?? '',
      email: email,
      phoneNumber: metadata['phone_number'] as String? ?? '',
      nim: '',
      verificationStatus: KtmVerificationStatus.unverified,
    );
    return AppResult.success(_currentUser!);
  }

  @override
  Future<AppResult<bool>> signInWithGoogle() async {
    if (_authService.isAvailable) {
      return _authService.signInWithGoogle();
    }

    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = const UserModel(
      id: 'usr_google_mock',
      fullName: 'Google User',
      email: 'user@google.com',
      phoneNumber: '',
      nim: '',
      verificationStatus: KtmVerificationStatus.unverified,
    );
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> sendOtp(String email) async {
    if (_authService.isAvailable) {
      return _authService.sendOtp(email);
    }

    await Future.delayed(const Duration(milliseconds: 200));
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> verifyOtp(String email, String token) async {
    if (_authService.isAvailable) {
      return _authService.verifyOtp(email, token);
    }

    await Future.delayed(const Duration(milliseconds: 200));
    if (token.length == 6) {
      return AppResult.success(true);
    }
    return AppResult.failure('Kode OTP tidak valid');
  }

  @override
  Future<void> logout() async {
    if (_authService.isAvailable) {
      await _authService.logout();
    }
    _currentUser = null;
    _signUpReturnedSession = false;
  }

  @override
  UserModel? getCurrentUser() {
    if (_currentUser != null) return _currentUser;
    if (_authService.isAvailable) {
      _currentUser = _authService.getCurrentUser();
    }
    return _currentUser;
  }

  @override
  bool didSignUpReturnSession() {
    if (_authService.isAvailable) {
      return _authService.hasActiveSession();
    }
    return _signUpReturnedSession;
  }
}
