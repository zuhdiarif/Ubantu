import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/config/app_config.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_profile_service.dart';
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

  UserModel? _cachedUser;

  Stream<AuthState>? get authStateChanges {
    if (!isAvailable) return null;
    return _effectiveClient.auth.onAuthStateChange;
  }

  UserModel? getCurrentUser() {
    if (!isAvailable) return null;
    final user = _effectiveClient.auth.currentUser;
    if (user == null) return null;
    if (_cachedUser != null && _cachedUser!.id == user.id) {
      return _cachedUser;
    }
    return _buildUserModel(user);
  }

  Future<UserModel> _mapUser(User user) async {
    Map<String, dynamic>? profileResponse;
    try {
      if (isAvailable) {
        profileResponse = await _effectiveClient
            .from('profiles')
            .select('verification_status, role')
            .eq('id', user.id)
            .maybeSingle();
      }
    } catch (_) {}

    final mapped = _buildUserModel(user, profileResponse);
    _cachedUser = mapped;
    return mapped;
  }

  UserModel _buildUserModel(User user, [Map<String, dynamic>? profileResponse]) {
    final meta = user.userMetadata ?? {};
    final fullName = meta['full_name'] as String? ?? user.email?.split('@').first ?? '';
    final phone = user.phone ?? (meta['phone_number'] as String? ?? '');
    final nim = meta['nim'] as String? ?? '';
    final avatarUrl = meta['avatar_url'] as String? ?? meta['picture'] as String?;
    final ktmPhotoUrl = meta['ktm_photo_url'] as String?;
    final verificationStatus = profileResponse != null
        ? (profileResponse['verification_status'] as String? ?? 'unverified')
        : (meta['verification_status'] as String?);
    final role = profileResponse != null
        ? (profileResponse['role'] as String? ?? 'customer')
        : (meta['role'] as String?);
    final genderStr = meta['gender'] as String?;
    final isFemaleOnly = meta['is_female_only_preferred'] as bool? ?? false;
    final rewardPoints = meta['reward_points'] as int? ?? 0;
    final faculty = profileResponse != null
        ? (profileResponse['faculty'] as String?)
        : (meta['faculty'] as String?);
    final bio = profileResponse != null
        ? (profileResponse['bio'] as String?)
        : (meta['bio'] as String?);
    final emailOtpSkipped = meta['email_otp_skipped'] as bool? ?? false;

    return UserModel(
      id: user.id,
      fullName: fullName,
      email: user.email ?? '',
      phoneNumber: phone,
      nim: nim,
      avatarUrl: avatarUrl,
      ktmPhotoUrl: ktmPhotoUrl,
      verificationStatus: verificationStatus != null
          ? KtmVerificationStatus.values.firstWhere(
              (e) => e.name == verificationStatus,
              orElse: () => nim.isNotEmpty
                  ? KtmVerificationStatus.verified
                  : (AppConfig.isUbEmail(user.email ?? '')
                      ? KtmVerificationStatus.pending
                      : KtmVerificationStatus.unverified),
            )
          : (nim.isNotEmpty
              ? KtmVerificationStatus.verified
              : (AppConfig.isUbEmail(user.email ?? '')
                  ? KtmVerificationStatus.pending
                  : KtmVerificationStatus.unverified)),
      role: role != null
          ? UserRole.values.firstWhere(
              (e) => e.name == role,
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
      faculty: faculty,
      bio: bio,
      emailOtpSkipped: emailOtpSkipped,
    );
  }

  bool _isEmailDeliveryUnavailable(AuthException e) {
    final msg = e.message.toLowerCase();
    final code = (e.code ?? '').toLowerCase();
    final status = e.statusCode ?? '';
    if (code == 'over_email_send_rate_limit' ||
        status == '429' ||
        (status == '500' && (msg.contains('sending') || msg.contains('email'))) ||
        msg.contains('error sending confirmation email') ||
        (msg.contains('error sending') && msg.contains('email')) ||
        msg.contains('email rate limit') ||
        msg.contains('over_email_send_rate_limit')) {
      return true;
    }
    return false;
  }

  String _mapAuthException(AuthException e) {
    final msg = e.message.toLowerCase();
    final code = (e.code ?? '').toLowerCase();
    if (msg.contains('expired') ||
        (msg.contains('invalid') && (msg.contains('otp') || msg.contains('token') || msg.contains('code'))) ||
        code.contains('otp_expired')) {
      return 'Kode OTP salah atau sudah kedaluwarsa';
    }
    if (msg.contains('rate limit') ||
        msg.contains('security purposes') ||
        msg.contains('too many requests') ||
        code.contains('over_email_send_rate_limit')) {
      return 'Terlalu banyak percobaan, coba lagi nanti';
    }
    if (msg.contains('user not found') || code.contains('user_not_found')) {
      return 'Pengguna tidak ditemukan';
    }
    if (msg.contains('already registered') || code.contains('user_already_exists')) {
      return 'Email sudah terdaftar';
    }
    if (msg.contains('invalid login credentials') || msg.contains('invalid credentials')) {
      return 'Email atau kata sandi salah';
    }
    return e.message;
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
      return AppResult.success(await _mapUser(user));
    } on AuthException catch (e) {
      return AppResult.failure(_mapAuthException(e));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<UserModel>> updateProfile(UserModel user) async {
    try {
      await updateUserMetadata({
        if (user.fullName.isNotEmpty) 'full_name': user.fullName,
        if (user.phoneNumber.isNotEmpty) 'phone_number': user.phoneNumber,
        'gender': user.gender.name,
        'is_female_only_preferred': user.isFemaleOnlyPreferred,
        if (user.faculty != null) 'faculty': user.faculty,
        if (user.bio != null) 'bio': user.bio,
      });
      final profileResult = await SupabaseProfileService(supabaseClient: _client).updateProfile(user);
      if (profileResult.isSuccess && profileResult.data != null) {
        _cachedUser = profileResult.data;
        return profileResult;
      }
      _cachedUser = user;
      return AppResult.success(user);
    } on AuthException catch (e) {
      return AppResult.failure(_mapAuthException(e));
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

      return AppResult.success(await _mapUser(user));
    } on AuthException catch (e) {
      return AppResult.failure(_mapAuthException(e));
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

      return AppResult.success(await _mapUser(user));
    } on AuthException catch (e) {
      if (_isEmailDeliveryUnavailable(e)) {
        return AppResult.failure(
          'Layanan email sedang sibuk.',
          errorCode: 'email_delivery_unavailable',
        );
      }
      return AppResult.failure(_mapAuthException(e));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<UserModel>> signUpFallback(
    String email,
    String password,
    Map<String, dynamic> metadata,
  ) async {
    try {
      final res = await _effectiveClient.functions.invoke(
        'signup-fallback',
        body: {
          'email': email,
          'password': password,
          'full_name': metadata['full_name'] ?? '',
          'phone_number': metadata['phone_number'] ?? '',
          ...metadata,
        },
      );
      if (res.status >= 400) {
        final data = res.data;
        final msg = data is Map ? (data['error'] ?? data['message'] ?? 'Gagal mendaftar') : 'Gagal mendaftar';
        return AppResult.failure(msg.toString());
      }
      return await login(email, password);
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
      return AppResult.failure(_mapAuthException(e));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> sendOtp(String email) async {
    try {
      await _effectiveClient.auth.signInWithOtp(email: email);
      return AppResult.success(true);
    } on AuthException catch (e) {
      return AppResult.failure(_mapAuthException(e));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> resendSignupOtp(String email) async {
    try {
      await _effectiveClient.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      return AppResult.success(true);
    } on AuthException catch (e) {
      if (_isEmailDeliveryUnavailable(e)) {
        return AppResult.failure(
          'Layanan email sedang sibuk.',
          errorCode: 'email_delivery_unavailable',
        );
      }
      return AppResult.failure(_mapAuthException(e));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> sendPasswordResetOtp(String email) async {
    try {
      await _effectiveClient.auth.resetPasswordForEmail(email);
      return AppResult.success(true);
    } on AuthException catch (e) {
      if (_isEmailDeliveryUnavailable(e)) {
        return AppResult.failure(
          'Layanan email sedang sibuk, coba lagi beberapa menit lagi.',
          errorCode: 'email_delivery_unavailable',
        );
      }
      return AppResult.failure(_mapAuthException(e));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> verifyOtp(String email, String token) async {
    try {
      final response = await _effectiveClient.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );

      if (response.user != null) {
        return AppResult.success(true);
      }
      return AppResult.failure('Verifikasi OTP gagal.');
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid') || e.message.toLowerCase().contains('expired')) {
        try {
          final fallback = await _effectiveClient.auth.verifyOTP(
            email: email,
            token: token,
            type: OtpType.email,
          );
          if (fallback.user != null) {
            return AppResult.success(true);
          }
        } catch (_) {}
      }
      return AppResult.failure(_mapAuthException(e));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> verifyRecoveryOtp(String email, String token) async {
    try {
      final response = await _effectiveClient.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );

      if (response.session != null) {
        return AppResult.success(true);
      }
      return AppResult.failure('Sesi verifikasi tidak valid.');
    } on AuthException catch (e) {
      return AppResult.failure(_mapAuthException(e));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> updatePassword(String newPassword) async {
    try {
      final response = await _effectiveClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (response.user != null) {
        return AppResult.success(true);
      }
      return AppResult.failure('Gagal memperbarui password.');
    } on AuthException catch (e) {
      return AppResult.failure(_mapAuthException(e));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<void> logout() async {
    _cachedUser = null;
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
