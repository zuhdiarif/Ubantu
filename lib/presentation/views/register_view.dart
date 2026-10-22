import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/custom_button.dart';
import 'package:ubantu/components/custom_input_field.dart';
import 'package:ubantu/components/custom_toast.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/core/utils/app_validators.dart';
import 'package:ubantu/core/utils/input_formatters.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/registration_provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onNext() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final regProvider = context.read<RegistrationProvider>();
    regProvider.setAccountDetails(
      fullName: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    final nextStep = await regProvider.signUp();

    if (!mounted) return;

    switch (nextStep) {
      case RegistrationNextStep.home:
        await context.read<AuthProvider>().login(
              _emailController.text,
              _passwordController.text,
            );
        if (mounted) {
          CustomToast.show(
            context,
            message: 'Akun berhasil dibuat! Selamat datang.',
            type: ToastType.success,
          );
          context.go(AppRouter.home);
        }
        break;
      case RegistrationNextStep.ktmVerification:
        context.push(AppRouter.ktmVerification);
        break;
      case RegistrationNextStep.otpVerification:
        await regProvider.sendOtp();
        if (mounted) {
          context.push(AppRouter.otpVerification);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final regProvider = context.watch<RegistrationProvider>();

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
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.onboarding);
            }
          },
        ),
        title: Text(
          'Daftar Akun',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomInputField(
                  label: 'Nama Lengkap',
                  placeholder: 'Masukkan nama lengkap',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 20),
                CustomInputField(
                  label: 'Email',
                  placeholder: 'Masukkan email aktif',
                  controller: _emailController,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.validateEmail,
                ),
                const SizedBox(height: 20),
                CustomInputField(
                  label: 'Nomor HP',
                  placeholder: '08XXXXXXXXXX',
                  controller: _phoneController,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [PhoneNumberInputFormatter()],
                  validator: AppValidators.validatePhone,
                ),
                const SizedBox(height: 20),
                CustomInputField(
                  label: 'Password',
                  placeholder: 'Minimal 8 karakter',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: AppValidators.validatePassword,
                ),
                const SizedBox(height: 36),
                CustomButton(
                  text: regProvider.isSigningUp ? 'Mendaftarkan...' : 'Lanjutkan',
                  onPressed: regProvider.isSigningUp ? () {} : _onNext,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: AppTypography.body1.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRouter.login),
                      child: Text(
                        'Masuk',
                        style: AppTypography.body1.copyWith(
                          color: const Color(0xFF0066FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
