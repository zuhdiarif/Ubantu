import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ubantu/core/config/app_config.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';
import 'package:ubantu/domain/usecases/resend_signup_otp_usecase.dart';
import 'package:ubantu/domain/usecases/send_otp_usecase.dart';
import 'package:ubantu/domain/usecases/verify_otp_usecase.dart';

enum RegistrationNextStep { home, ktmVerification, otpVerification, otpSkipped }

class RegistrationProvider extends ChangeNotifier {
  final IAuthRepository _repository;
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResendSignupOtpUseCase _resendSignupOtpUseCase;

  RegistrationProvider({
    IAuthRepository? repository,
    ResendSignupOtpUseCase? resendSignupOtpUseCase,
  })  : _repository = repository ?? AuthRepositoryImpl(),
        _sendOtpUseCase = SendOtpUseCase(repository ?? AuthRepositoryImpl()),
        _verifyOtpUseCase = VerifyOtpUseCase(repository ?? AuthRepositoryImpl()),
        _resendSignupOtpUseCase = resendSignupOtpUseCase ??
            ResendSignupOtpUseCase(repository ?? AuthRepositoryImpl());

  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _password = '';
  String _nim = '';
  String? _ktmPhotoPath;
  KtmVerificationStatus _ktmStatus = KtmVerificationStatus.unverified;
  bool _isOtpVerifying = false;
  bool _isSigningUp = false;
  String? _otpError;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  bool _emailOtpSkipped = false;

  String get fullName => _fullName;
  String get email => _email;
  String get phone => _phone;
  String get password => _password;
  String get nim => _nim;
  String? get ktmPhotoPath => _ktmPhotoPath;
  KtmVerificationStatus get ktmStatus => _ktmStatus;
  bool get isOtpVerifying => _isOtpVerifying;
  bool get isSigningUp => _isSigningUp;
  String? get otpError => _otpError;
  int get resendCooldown => _resendCooldown;
  bool get canResendOtp => _resendCooldown == 0;
  bool get emailOtpSkipped => _emailOtpSkipped;
  bool get isUbEmail => AppConfig.isUbEmail(_email);

  void _startCooldown([int seconds = 60]) {
    _resendCooldown = seconds;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        _resendCooldown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
    notifyListeners();
  }

  void setAccountDetails({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    _fullName = fullName;
    _email = email;
    _phone = phone;
    _password = password;
    notifyListeners();
  }

  void setKtmData({required String nim, String? photoPath}) {
    _nim = nim;
    _ktmPhotoPath = photoPath;
    _ktmStatus = KtmVerificationStatus.pending;
    notifyListeners();
  }

  void updateKtmStatus(KtmVerificationStatus status) {
    _ktmStatus = status;
    notifyListeners();
  }

  Future<RegistrationNextStep> signUp() async {
    _isSigningUp = true;
    notifyListeners();

    final result = await _repository.signUp(_email, _password, {
      'full_name': _fullName,
      'phone_number': _phone,
    });

    _isSigningUp = false;
    notifyListeners();

    if (!result.isSuccess) {
      if (result.errorCode == 'email_delivery_unavailable' ||
          (result.errorMessage ?? '').contains('email_delivery_unavailable')) {
        final fallbackResult = await _repository.signUpFallback(_email, _password, {
          'full_name': _fullName,
          'phone_number': _phone,
        });
        _isSigningUp = false;
        notifyListeners();
        if (fallbackResult.isSuccess) {
          _emailOtpSkipped = true;
          _ktmStatus = KtmVerificationStatus.unverified;
          notifyListeners();
          if (isUbEmail) {
            return RegistrationNextStep.ktmVerification;
          }
          return RegistrationNextStep.otpSkipped;
        } else {
          _otpError = fallbackResult.errorMessage ?? 'Gagal mendaftar akun';
          return RegistrationNextStep.otpVerification;
        }
      }
      _isSigningUp = false;
      notifyListeners();
      _startCooldown(60);
      return RegistrationNextStep.otpVerification;
    }

    if (_repository.didSignUpReturnSession() || !AppConfig.confirmEmailEnabled) {
      return RegistrationNextStep.home;
    }

    if (isUbEmail) {
      return RegistrationNextStep.ktmVerification;
    }

    _startCooldown(60);
    return RegistrationNextStep.otpVerification;
  }

  Future<bool> sendOtp() async {
    final result = await _sendOtpUseCase.execute(_email);
    return result.isSuccess;
  }

  Future<AppResult<bool>> resendOtp() async {
    if (_resendCooldown > 0) {
      return AppResult.failure('Tunggu $_resendCooldown detik sebelum mengirim ulang.');
    }
    final result = await _resendSignupOtpUseCase.execute(_email);
    if (result.isSuccess) {
      _startCooldown(60);
    }
    return result;
  }

  Future<bool> verifyOtp(String token) async {
    _isOtpVerifying = true;
    _otpError = null;
    notifyListeners();

    final result = await _verifyOtpUseCase.execute(_email, token);
    _isOtpVerifying = false;

    if (result.isSuccess) {
      _ktmStatus = KtmVerificationStatus.verified;
      notifyListeners();
      return true;
    } else {
      _otpError = result.errorMessage ?? 'Kode OTP salah atau sudah kedaluwarsa';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
