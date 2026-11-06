import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';
import 'package:ubantu/domain/usecases/send_password_reset_otp_usecase.dart';
import 'package:ubantu/domain/usecases/update_password_usecase.dart';
import 'package:ubantu/domain/usecases/verify_recovery_otp_usecase.dart';

enum PasswordResetStep { enterEmail, enterCode, done }

class PasswordResetProvider extends ChangeNotifier {
  final IAuthRepository _repository;
  final SendPasswordResetOtpUseCase _sendOtpUseCase;
  final VerifyRecoveryOtpUseCase _verifyRecoveryOtpUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;

  PasswordResetProvider({
    IAuthRepository? repository,
    SendPasswordResetOtpUseCase? sendOtpUseCase,
    VerifyRecoveryOtpUseCase? verifyRecoveryOtpUseCase,
    UpdatePasswordUseCase? updatePasswordUseCase,
  })  : _repository = repository ?? AuthRepositoryImpl(),
        _sendOtpUseCase = sendOtpUseCase ??
            SendPasswordResetOtpUseCase(repository ?? AuthRepositoryImpl()),
        _verifyRecoveryOtpUseCase = verifyRecoveryOtpUseCase ??
            VerifyRecoveryOtpUseCase(repository ?? AuthRepositoryImpl()),
        _updatePasswordUseCase = updatePasswordUseCase ??
            UpdatePasswordUseCase(repository ?? AuthRepositoryImpl());

  PasswordResetStep _step = PasswordResetStep.enterEmail;
  String _email = '';
  bool _isLoading = false;
  String? _errorMessage;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  PasswordResetStep get step => _step;
  String get email => _email;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get resendCooldown => _resendCooldown;
  bool get canResend => _resendCooldown == 0;

  void setEmail(String email) {
    _email = email.trim();
    notifyListeners();
  }

  void setStep(PasswordResetStep step) {
    _step = step;
    _errorMessage = null;
    notifyListeners();
  }

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

  Future<bool> sendCode(String email) async {
    _email = email.trim();
    if (_email.isEmpty) {
      _errorMessage = 'Email tidak boleh kosong';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _sendOtpUseCase.execute(_email);
    _isLoading = false;

    if (result.isSuccess) {
      _step = PasswordResetStep.enterCode;
      _startCooldown(60);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage ?? 'Gagal mengirim kode OTP';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendCode() async {
    if (!canResend) {
      _errorMessage = 'Tunggu $_resendCooldown detik sebelum meminta kode baru';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _sendOtpUseCase.execute(_email);
    _isLoading = false;

    if (result.isSuccess) {
      _startCooldown(60);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage ?? 'Gagal mengirim ulang kode OTP';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyAndReset(String code, String newPassword) async {
    final cleanCode = code.trim();
    final cleanPassword = newPassword.trim();

    if (cleanCode.length != 6) {
      _errorMessage = 'Masukkan 6 digit kode OTP';
      notifyListeners();
      return false;
    }

    if (cleanPassword.length < 8) {
      _errorMessage = 'Password minimal 8 karakter';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final verifyResult = await _verifyRecoveryOtpUseCase.execute(_email, cleanCode);
    if (!verifyResult.isSuccess) {
      _isLoading = false;
      _errorMessage = verifyResult.errorMessage ?? 'Kode OTP salah atau sudah kedaluwarsa';
      notifyListeners();
      return false;
    }

    final updateResult = await _updatePasswordUseCase.execute(cleanPassword);
    if (!updateResult.isSuccess) {
      _isLoading = false;
      _errorMessage = updateResult.errorMessage ?? 'Gagal memperbarui password';
      notifyListeners();
      return false;
    }

    await _repository.logout();
    _step = PasswordResetStep.done;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void reset() {
    _step = PasswordResetStep.enterEmail;
    _email = '';
    _errorMessage = null;
    _isLoading = false;
    _cooldownTimer?.cancel();
    _resendCooldown = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
