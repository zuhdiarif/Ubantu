import 'package:flutter/material.dart';
import 'package:ubantu/core/config/app_config.dart';
import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';
import 'package:ubantu/domain/usecases/send_otp_usecase.dart';
import 'package:ubantu/domain/usecases/verify_otp_usecase.dart';

enum RegistrationNextStep { home, ktmVerification, otpVerification }

class RegistrationProvider extends ChangeNotifier {
  final IAuthRepository _repository;
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;

  RegistrationProvider({IAuthRepository? repository})
      : _repository = repository ?? AuthRepositoryImpl(),
        _sendOtpUseCase = SendOtpUseCase(repository ?? AuthRepositoryImpl()),
        _verifyOtpUseCase = VerifyOtpUseCase(repository ?? AuthRepositoryImpl());

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
  bool get isUbEmail => AppConfig.isUbEmail(_email);

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
      return RegistrationNextStep.otpVerification;
    }

    if (_repository.didSignUpReturnSession() || !AppConfig.confirmEmailEnabled) {
      return RegistrationNextStep.home;
    }

    if (isUbEmail) {
      return RegistrationNextStep.ktmVerification;
    }

    return RegistrationNextStep.otpVerification;
  }

  Future<bool> sendOtp() async {
    final result = await _sendOtpUseCase.execute(_email);
    return result.isSuccess;
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
      _otpError = result.errorMessage ?? 'Kode OTP salah';
      notifyListeners();
      return false;
    }
  }
}
