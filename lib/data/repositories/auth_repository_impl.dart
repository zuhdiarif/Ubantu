import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/user_model.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  UserModel? _currentUser;
  bool _signUpReturnedSession = false;

  @override
  Future<AppResult<UserModel>> login(String email, String password) async {
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
  Future<AppResult<bool>> sendOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> verifyOtp(String email, String token) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (token.length == 6) {
      return AppResult.success(true);
    }
    return AppResult.failure('Kode OTP tidak valid');
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _signUpReturnedSession = false;
  }

  @override
  UserModel? getCurrentUser() => _currentUser;

  @override
  bool didSignUpReturnSession() => _signUpReturnedSession;
}
