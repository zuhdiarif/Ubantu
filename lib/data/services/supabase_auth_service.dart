import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/user_model.dart';

class SupabaseAuthService {
  final SupabaseClient? _client;

  SupabaseAuthService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  bool get isAvailable {
    if (_client != null) return true;
    return SupabaseService.instance.isInitialized;
  }

  Stream<AuthState>? get authStateChanges {
    if (!isAvailable) return null;
    return _effectiveClient.auth.onAuthStateChange;
  }

  UserModel? getCurrentUser() {
    if (!isAvailable) return null;
    final user = _effectiveClient.auth.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  UserModel _mapUser(User user) {
    final meta = user.userMetadata ?? {};
    final fullName = meta['full_name'] as String? ?? user.email?.split('@').first ?? '';
    final phone = user.phone ?? (meta['phone_number'] as String? ?? '');
    final nim = meta['nim'] as String? ?? '';
    final avatarUrl = meta['avatar_url'] as String? ?? meta['picture'] as String?;
    final ktmPhotoUrl = meta['ktm_photo_url'] as String?;
    final roleStr = meta['role'] as String?;
    final genderStr = meta['gender'] as String?;
    final isFemaleOnly = meta['is_female_only_preferred'] as bool? ?? false;
    final rewardPoints = meta['reward_points'] as int? ?? 0;
    final verificationStatusStr = meta['verification_status'] as String?;

    return UserModel(
      id: user.id,
      fullName: fullName,
      email: user.email ?? '',
      phoneNumber: phone,
      nim: nim,
      avatarUrl: avatarUrl,
      ktmPhotoUrl: ktmPhotoUrl,
      verificationStatus: verificationStatusStr != null
          ? KtmVerificationStatus.values.firstWhere(
              (e) => e.name == verificationStatusStr,
              orElse: () => nim.isNotEmpty
                  ? KtmVerificationStatus.verified
                  : KtmVerificationStatus.unverified,
            )
          : (nim.isNotEmpty
              ? KtmVerificationStatus.verified
              : KtmVerificationStatus.unverified),
      role: roleStr != null
          ? UserRole.values.firstWhere(
              (e) => e.name == roleStr,
              orElse: () => UserRole.customer,
            )
          : UserRole.customer,
      gender: genderStr != null
          ? UserGender.values.firstWhere(
              (e) => e.name == genderStr,
              orElse: () => UserGender.unspecified,
            )
          : UserGender.unspecified,
      isFemaleOnlyPreferred: isFemaleOnly,
      rewardPoints: rewardPoints,
    );
  }

  Future<AppResult<UserModel>> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      final response = await _effectiveClient.auth.updateUser(
        UserAttributes(data: metadata),
      );
      final user = response.user;
      if (user == null) {
        return AppResult.failure('Gagal memperbarui metadata pengguna.');
      }
      return AppResult.success(_mapUser(user));
    } on AuthException catch (e) {
      return AppResult.failure(e.message);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<UserModel>> login(String email, String password) async {
    try {
      final response = await _effectiveClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return AppResult.failure('Gagal masuk, data pengguna tidak ditemukan.');
      }

      return AppResult.success(_mapUser(user));
    } on AuthException catch (e) {
      return AppResult.failure(e.message);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<UserModel>> signUp(
    String email,
    String password,
    Map<String, dynamic> metadata,
  ) async {
    try {
      final response = await _effectiveClient.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );

      final user = response.user;
      if (user == null) {
        return AppResult.failure('Gagal mendaftar.');
      }

      return AppResult.success(_mapUser(user));
    } on AuthException catch (e) {
      return AppResult.failure(e.message);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> signInWithGoogle() async {
    try {
      final success = await _effectiveClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.ubantu://login-callback/',
      );

      return AppResult.success(success);
    } on AuthException catch (e) {
      return AppResult.failure(e.message);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> sendOtp(String email) async {
    try {
      await _effectiveClient.auth.signInWithOtp(email: email);
      return AppResult.success(true);
    } on AuthException catch (e) {
      return AppResult.failure(e.message);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> verifyOtp(String email, String token) async {
    try {
      final response = await _effectiveClient.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );

      if (response.user != null) {
        return AppResult.success(true);
      }
      return AppResult.failure('Verifikasi OTP gagal.');
    } on AuthException catch (e) {
      return AppResult.failure(e.message);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<void> logout() async {
    if (!isAvailable) return;
    try {
      await _effectiveClient.auth.signOut();
    } catch (_) {}
  }

  bool hasActiveSession() {
    if (!isAvailable) return false;
    return _effectiveClient.auth.currentSession != null;
  }
}
