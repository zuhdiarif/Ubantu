import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/user_model.dart';
import 'package:ubantu/data/repositories/auth_repository.dart';
import 'package:ubantu/logic/resend_signup_otp_usecase.dart';
import 'package:ubantu/logic/send_password_reset_otp_usecase.dart';
import 'package:ubantu/logic/update_password_usecase.dart';
import 'package:ubantu/logic/update_user_profile_usecase.dart';
import 'package:ubantu/logic/verify_recovery_otp_usecase.dart';
import 'package:ubantu/ui/auth/password_reset_provider.dart';
import 'package:ubantu/ui/auth/registration_provider.dart';
import 'package:ubantu/ui/auth/forgot_password_view.dart';

class _FakeAuthRepository implements IAuthRepository {
  UserModel? currentUser;
  bool returnSessionOnSignUp = false;
  bool shouldFailEmailDelivery = false;
  bool shouldFailOtherError = false;
  bool fallbackCalled = false;
  bool logoutCalled = false;
  String? updatedPassword;
  String? lastRecoveryCode;

  @override
  Future<AppResult<bool>> deleteAccount() async {
    currentUser = null;
    return AppResult.success(true);
  }

  @override
  Future<AppResult<UserModel>> login(String email, String password) async {
    currentUser = UserModel(
      id: 'usr_test',
      fullName: 'Test User',
      email: email,
      phoneNumber: '081234567890',
      nim: '',
    );
    return AppResult.success(currentUser!);
  }

  @override
  Future<AppResult<UserModel>> signUp(
    String email,
    String password,
    Map<String, dynamic> metadata,
  ) async {
    if (shouldFailEmailDelivery) {
      return AppResult.failure(
        'Layanan email sedang sibuk.',
        errorCode: 'email_delivery_unavailable',
      );
    }
    if (shouldFailOtherError) {
      return AppResult.failure('Email sudah terdaftar');
    }
    currentUser = UserModel(
      id: 'usr_reg',
      fullName: metadata['full_name'] as String? ?? '',
      email: email,
      phoneNumber: metadata['phone_number'] as String? ?? '',
      nim: '',
    );
    return AppResult.success(currentUser!);
  }

  @override
  Future<AppResult<UserModel>> signUpFallback(
    String email,
    String password,
    Map<String, dynamic> metadata,
  ) async {
    fallbackCalled = true;
    currentUser = UserModel(
      id: 'usr_fallback',
      fullName: metadata['full_name'] as String? ?? '',
      email: email,
      phoneNumber: metadata['phone_number'] as String? ?? '',
      nim: '',
      emailOtpSkipped: true,
    );
    return AppResult.success(currentUser!);
  }

  @override
  Future<AppResult<bool>> sendOtp(String email) async => AppResult.success(true);

  @override
  Future<AppResult<bool>> resendSignupOtp(String email) async {
    if (shouldFailEmailDelivery) {
      return AppResult.failure(
        'Layanan email sedang sibuk.',
        errorCode: 'email_delivery_unavailable',
      );
    }
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> sendPasswordResetOtp(String email) async {
    if (email.contains('notfound')) {
      return AppResult.failure('Pengguna tidak ditemukan');
    }
    if (shouldFailEmailDelivery) {
      return AppResult.failure(
        'Layanan email sedang sibuk, coba lagi beberapa menit lagi.',
        errorCode: 'email_delivery_unavailable',
      );
    }
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> verifyOtp(String email, String token) async {
    if (token == '123456') return AppResult.success(true);
    return AppResult.failure('Kode OTP salah atau sudah kedaluwarsa');
  }

  @override
  Future<AppResult<bool>> verifyRecoveryOtp(String email, String token) async {
    lastRecoveryCode = token;
    if (token == '654321') return AppResult.success(true);
    return AppResult.failure('Kode OTP salah atau sudah kedaluwarsa');
  }

  @override
  Future<AppResult<bool>> updatePassword(String newPassword) async {
    if (newPassword.length < 8) {
      return AppResult.failure('Password minimal 8 karakter');
    }
    updatedPassword = newPassword;
    return AppResult.success(true);
  }

  @override
  Future<AppResult<UserModel>> updateProfile(UserModel user) async {
    currentUser = user;
    return AppResult.success(user);
  }

  @override
  Future<AppResult<bool>> signInWithGoogle() async => AppResult.success(true);

  @override
  Future<void> logout() async {
    logoutCalled = true;
    currentUser = null;
  }

  @override
  UserModel? getCurrentUser() => currentUser;

  @override
  bool didSignUpReturnSession() => returnSessionOnSignUp;
}

void main() {
  group('Squad E Auth OTP UseCases Tests', () {
    late _FakeAuthRepository repository;

    setUp(() {
      repository = _FakeAuthRepository();
    });

    test('ResendSignupOtpUseCase executes resendSignupOtp on repository', () async {
      final useCase = ResendSignupOtpUseCase(repository);
      final result = await useCase.execute('student@ub.ac.id');
      expect(result.isSuccess, isTrue);

      repository.shouldFailEmailDelivery = true;
      final failResult = await useCase.execute('student@ub.ac.id');
      expect(failResult.isSuccess, isFalse);
      expect(failResult.errorCode, 'email_delivery_unavailable');
    });

    test('SendPasswordResetOtpUseCase executes sendPasswordResetOtp on repository', () async {
      final useCase = SendPasswordResetOtpUseCase(repository);
      final result = await useCase.execute('student@ub.ac.id');
      expect(result.isSuccess, isTrue);

      final notFoundResult = await useCase.execute('notfound@ub.ac.id');
      expect(notFoundResult.isSuccess, isFalse);
      expect(notFoundResult.errorMessage, 'Pengguna tidak ditemukan');
    });

    test('VerifyRecoveryOtpUseCase validates recovery OTP token', () async {
      final useCase = VerifyRecoveryOtpUseCase(repository);
      final successResult = await useCase.execute('student@ub.ac.id', '654321');
      expect(successResult.isSuccess, isTrue);

      final failResult = await useCase.execute('student@ub.ac.id', '000000');
      expect(failResult.isSuccess, isFalse);
      expect(failResult.errorMessage, 'Kode OTP salah atau sudah kedaluwarsa');
    });

    test('UpdatePasswordUseCase updates user password', () async {
      final useCase = UpdatePasswordUseCase(repository);
      final successResult = await useCase.execute('newPassword123');
      expect(successResult.isSuccess, isTrue);
      expect(repository.updatedPassword, 'newPassword123');

      final failResult = await useCase.execute('short');
      expect(failResult.isSuccess, isFalse);
    });

    test('UpdateUserProfileUseCase delegates to repository updateProfile', () async {
      final useCase = UpdateUserProfileUseCase(repository);
      const user = UserModel(
        id: 'usr_update',
        fullName: 'Budi Santoso',
        email: 'budi@student.ub.ac.id',
        phoneNumber: '08123456789',
        nim: '215150200111001',
      );
      final result = await useCase.execute(user);
      expect(result.isSuccess, isTrue);
      expect(repository.currentUser?.fullName, 'Budi Santoso');
    });
  });

  group('Squad E PasswordResetProvider State Management Tests', () {
    late _FakeAuthRepository repository;
    late PasswordResetProvider provider;

    setUp(() {
      repository = _FakeAuthRepository();
      provider = PasswordResetProvider(repository: repository);
    });

    tearDown(() {
      provider.dispose();
    });

    test('sendCode transitions to enterCode step and starts cooldown', () async {
      expect(provider.step, PasswordResetStep.enterEmail);
      final ok = await provider.sendCode('student@ub.ac.id');
      expect(ok, isTrue);
      expect(provider.step, PasswordResetStep.enterCode);
      expect(provider.email, 'student@ub.ac.id');
      expect(provider.resendCooldown, 60);
      expect(provider.canResend, isFalse);
    });

    test('sendCode fails with empty email', () async {
      final ok = await provider.sendCode('');
      expect(ok, isFalse);
      expect(provider.errorMessage, 'Email tidak boleh kosong');
      expect(provider.step, PasswordResetStep.enterEmail);
    });

    test('resendCode is blocked while cooldown is active', () async {
      await provider.sendCode('student@ub.ac.id');
      final resendOk = await provider.resendCode();
      expect(resendOk, isFalse);
      expect(provider.errorMessage, contains('Tunggu'));
    });

    test('verifyAndReset fails on invalid code length or short password', () async {
      await provider.sendCode('student@ub.ac.id');

      final shortCode = await provider.verifyAndReset('123', 'password123');
      expect(shortCode, isFalse);
      expect(provider.errorMessage, 'Masukkan 6 digit kode OTP');

      final shortPass = await provider.verifyAndReset('654321', 'pass');
      expect(shortPass, isFalse);
      expect(provider.errorMessage, 'Password minimal 8 karakter');
    });

    test('verifyAndReset wrong recovery code fails', () async {
      await provider.sendCode('student@ub.ac.id');
      final result = await provider.verifyAndReset('000000', 'newPassword123');
      expect(result, isFalse);
      expect(provider.errorMessage, 'Kode OTP salah atau sudah kedaluwarsa');
      expect(provider.step, PasswordResetStep.enterCode);
    });

    test('verifyAndReset full success path resets password, logs out, and completes', () async {
      await provider.sendCode('student@ub.ac.id');
      final result = await provider.verifyAndReset('654321', 'newPassword123');
      expect(result, isTrue);
      expect(provider.step, PasswordResetStep.done);
      expect(repository.updatedPassword, 'newPassword123');
      expect(repository.logoutCalled, isTrue);
    });
  });

  group('Squad E RegistrationProvider Fallback on Email Rate Limit Tests', () {
    late _FakeAuthRepository repository;
    late RegistrationProvider provider;

    setUp(() {
      repository = _FakeAuthRepository();
      provider = RegistrationProvider(repository: repository);
    });

    tearDown(() {
      provider.dispose();
    });

    test('signUp automatically executes fallback when email delivery fails and skips OTP for non-UB email', () async {
      repository.shouldFailEmailDelivery = true;

      provider.setAccountDetails(
        fullName: 'Jane Doe',
        email: 'janedoe@gmail.com',
        phone: '081234567890',
        password: 'password123',
      );

      final nextStep = await provider.signUp();

      expect(repository.fallbackCalled, isTrue);
      expect(provider.emailOtpSkipped, isTrue);
      expect(nextStep, RegistrationNextStep.otpSkipped);
    });

    test('signUp automatically executes fallback and goes to ktmVerification for UB email', () async {
      repository.shouldFailEmailDelivery = true;

      provider.setAccountDetails(
        fullName: 'Mahasiswa Brawijaya',
        email: 'mhs@student.ub.ac.id',
        phone: '081234567890',
        password: 'password123',
      );

      final nextStep = await provider.signUp();

      expect(repository.fallbackCalled, isTrue);
      expect(provider.emailOtpSkipped, isTrue);
      expect(nextStep, RegistrationNextStep.ktmVerification);
    });

    test('signUp does NOT trigger fallback on non-email-delivery errors', () async {
      repository.shouldFailOtherError = true;

      provider.setAccountDetails(
        fullName: 'Jane Doe',
        email: 'janedoe@gmail.com',
        phone: '081234567890',
        password: 'password123',
      );

      final nextStep = await provider.signUp();

      expect(repository.fallbackCalled, isFalse);
      expect(provider.emailOtpSkipped, isFalse);
      expect(nextStep, RegistrationNextStep.failed);
      expect(provider.signUpError, isNotNull);
    });
  });

  group('Squad E ForgotPasswordView Widget Tests', () {
    testWidgets('ForgotPasswordView step 1 transitions to step 2 and back', (tester) async {
      final repository = _FakeAuthRepository();
      final provider = PasswordResetProvider(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: ForgotPasswordView(provider: provider),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Atur Ulang Kata Sandi'), findsOneWidget);
      expect(find.text('Kirim Kode'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'mhs@student.ub.ac.id');
      await tester.tap(find.text('Kirim Kode'));
      await tester.pumpAndSettle();

      expect(find.text('Verifikasi Kode & Sandi Baru'), findsOneWidget);
      expect(find.text('mhs@student.ub.ac.id'), findsOneWidget);
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Ganti email'), findsOneWidget);

      await tester.tap(find.text('Ganti email'));
      await tester.pumpAndSettle();

      expect(find.text('Atur Ulang Kata Sandi'), findsOneWidget);
      provider.dispose();
    });
  });
}
