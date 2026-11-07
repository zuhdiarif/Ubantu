import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ubantu/core/config/app_config.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/user_model.dart';
import 'package:ubantu/data/repositories/auth_repository.dart';
import 'package:ubantu/logic/resend_signup_otp_usecase.dart';
import 'package:ubantu/logic/send_otp_usecase.dart';
import 'package:ubantu/logic/verify_otp_usecase.dart';

enum RegistrationNextStep { home, ktmVerification, otpVerification, otpSkipped, failed }

class RegistrationProvider extends ChangeNotifier {
  final IAuthRepository _repository;
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResendSignupOtpUseCase _resendSignupOtpUseCase;

  RegistrationProvider({
    IAuthRepository? repository,
    ResendSignupOtpUseCase? resendSignupOtpUseCase,
  })  : _repository = repository ?? ServiceLocator.instance.authRepository,
        _sendOtpUseCase = SendOtpUseCase(repository ?? ServiceLocator.instance.authRepository),
        _verifyOtpUseCase = VerifyOtpUseCase(repository ?? ServiceLocator.instance.authRepository),
        _resendSignupOtpUseCase = resendSignupOtpUseCase ??
            ResendSignupOtpUseCase(repository ?? ServiceLocator.instance.authRepository);

  IAuthRepository get repository => _repository;

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
  String? _signUpError;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  bool _emailOtpSkipped = false;
  UserModel? _registeredUser;

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
  String? get signUpError => _signUpError;
  int get resendCooldown => _resendCooldown;
  bool get canResendOtp => _resendCooldown == 0;
  bool get emailOtpSkipped => _emailOtpSkipped;
  bool get isUbEmail => AppConfig.isUbEmail(_email);
  UserModel? get registeredUser => _registeredUser;

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
    _signUpError = null;
    notifyListeners();

    final result = await _repository.signUp(_email, _password, {
      'full_name': _fullName,
      'phone_number': _phone,
    });

    _isSigningUp = false;
    notifyListeners();

    if (!result.isSuccess) {
      if (result.errorCode == 'email_delivery_unavailable' ||
          result.errorMessage == 'email_delivery_unavailable') {
        final fallbackResult = await _repository.signUpFallback(_email, _password, {
          'full_name': _fullName,
          'phone_number': _phone,
        });
        _isSigningUp = false;
        notifyListeners();
        if (fallbackResult.isSuccess) {
          _registeredUser = fallbackResult.data ?? _repository.getCurrentUser();
          _emailOtpSkipped = true;
          notifyListeners();
          if (isUbEmail) {
            return RegistrationNextStep.ktmVerification;
          }
          return RegistrationNextStep.otpSkipped;
        } else {
          _otpError = fallbackResult.errorMessage ?? 'Gagal mendaftar akun';
          await sendOtp();
          return RegistrationNextStep.otpVerification;
        }
      }
      _isSigningUp = false;
      _signUpError = result.errorMessage ?? 'Registrasi gagal. Periksa kembali data Anda.';
      notifyListeners();
      return RegistrationNextStep.failed;
    }

    _registeredUser = result.data ?? _repository.getCurrentUser();

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
      notifyListeners();
      return true;
    } else {
      _otpError = result.errorMessage ?? 'Kode OTP salah atau sudah kedaluwarsa';
      notifyListeners();
      return false;
    }
  }

  void resetSession() {
    _fullName = '';
    _email = '';
    _phone = '';
    _password = '';
    _nim = '';
    _ktmPhotoPath = null;
    _ktmStatus = KtmVerificationStatus.unverified;
    _isOtpVerifying = false;
    _isSigningUp = false;
    _otpError = null;
    _signUpError = null;
    _cooldownTimer?.cancel();
    _resendCooldown = 0;
    _emailOtpSkipped = false;
    _registeredUser = null;
    notifyListeners();
  }

  void reset() => resetSession();

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
