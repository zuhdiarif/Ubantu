import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/custom_button.dart';
import 'package:ubantu/components/custom_input_field.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/core/utils/app_validators.dart';
import 'package:ubantu/presentation/providers/password_reset_provider.dart';

class ForgotPasswordView extends StatefulWidget {
  final PasswordResetProvider? provider;

  const ForgotPasswordView({super.key, this.provider});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmitEmail(PasswordResetProvider provider) async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final ok = await provider.sendCode(email);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode OTP berhasil dikirimkan ke $email'),
          backgroundColor: AppColors.primaryDark,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal mengirim kode OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onSubmitReset(PasswordResetProvider provider) async {
    if (!(_resetFormKey.currentState?.validate() ?? false)) return;

    final code = _codeController.text.trim();
    final password = _newPasswordController.text;

    final ok = await provider.verifyAndReset(code, password);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diubah, silakan masuk'),
          backgroundColor: AppColors.primaryDark,
        ),
      );
      context.go(AppRouter.login);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal mengatur ulang kata sandi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.provider != null) {
      return ChangeNotifierProvider.value(
        value: widget.provider!,
        child: Builder(
          builder: (ctx) => _buildScaffold(ctx),
        ),
      );
    }
    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) {
    final provider = context.watch<PasswordResetProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryDark,
          ),
          onPressed: () {
            if (provider.step == PasswordResetStep.enterCode) {
              provider.setStep(PasswordResetStep.enterEmail);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Lupa Password',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: provider.step == PasswordResetStep.enterEmail
              ? _buildStepEmail(context, provider)
              : _buildStepCode(context, provider),
        ),
      ),
    );
  }

  Widget _buildStepEmail(BuildContext context, PasswordResetProvider provider) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 40,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Atur Ulang Kata Sandi',
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Masukkan email akun UBantu kamu. Kami akan mengirimkan 6-digit kode OTP untuk verifikasi.',
              textAlign: TextAlign.center,
              style: AppTypography.body1.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 32),
          CustomInputField(
            label: 'Email',
            placeholder: 'nama@student.ub.ac.id',
            controller: _emailController,
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: AppValidators.validateEmail,
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: provider.isLoading ? 'Mengirim...' : 'Kirim Kode',
            icon: Icons.send_rounded,
            onPressed: provider.isLoading ? null : () => _onSubmitEmail(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCode(BuildContext context, PasswordResetProvider provider) {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                size: 40,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Verifikasi Kode & Sandi Baru',
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Kode OTP telah dikirimkan ke:',
              textAlign: TextAlign.center,
              style: AppTypography.body2.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              provider.email,
              textAlign: TextAlign.center,
              style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: () => provider.setStep(PasswordResetStep.enterEmail),
              child: Text(
                'Ganti email',
                style: AppTypography.body2.copyWith(
                  color: const Color(0xFF0066FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomInputField(
            label: 'Kode OTP (6 Digit)',
            placeholder: '123456',
            controller: _codeController,
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (value) {
              if (value == null || value.trim().length != 6) {
                return 'Masukkan 6 digit kode OTP';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomInputField(
            label: 'Password Baru',
            placeholder: 'Minimal 8 karakter',
            controller: _newPasswordController,
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: _obscureNewPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey.shade500,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            validator: AppValidators.validatePassword,
          ),
          const SizedBox(height: 16),
          CustomInputField(
            label: 'Konfirmasi Password Baru',
            placeholder: 'Ulangi password baru',
            controller: _confirmPasswordController,
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey.shade500,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi password tidak boleh kosong';
              }
              if (value != _newPasswordController.text) {
                return 'Password baru tidak cocok';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tidak menerima kode? ',
                style: AppTypography.body2.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              provider.canResend
                  ? GestureDetector(
                      onTap: () async {
                        final ok = await provider.resendCode();
                        if (!context.mounted) return;
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kode OTP baru telah dikirimkan.'),
                              backgroundColor: AppColors.primaryDark,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(provider.errorMessage ?? 'Gagal mengirim ulang OTP'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Kirim Ulang',
                        style: AppTypography.body2.copyWith(
                          color: const Color(0xFF0066FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Text(
                      'Kirim ulang dalam ${provider.resendCooldown}s',
                      style: AppTypography.body2.copyWith(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 28),
          CustomButton(
            text: provider.isLoading ? 'Memproses...' : 'Reset Password',
            icon: Icons.check_circle_outline_rounded,
            onPressed: provider.isLoading ? null : () => _onSubmitReset(provider),
          ),
        ],
      ),
    );
  }
}
