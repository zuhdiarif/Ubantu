import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/ui/widgets/custom_button.dart';
import 'package:ubantu/ui/widgets/custom_input_field.dart';
import 'package:ubantu/ui/widgets/custom_toast.dart';
import 'package:ubantu/core/theme/app_colors.dart';
import 'package:ubantu/core/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/core/utils/app_validators.dart';
import 'package:ubantu/core/utils/input_formatters.dart';
import 'package:ubantu/ui/auth/auth_provider.dart';
import 'package:ubantu/ui/auth/registration_provider.dart';

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
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showTermsDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Syarat & Ketentuan UBantu',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            '1. Pengguna wajib memberikan data yang valid dan dapat dipertanggungjawabkan.\n\n'
            '2. Mahasiswa wajib memverifikasi identitas dengan KTM resmi dari kampus.\n\n'
            '3. Pengguna dilarang menyalahgunakan layanan, melakukan tindakan ilegal, atau membahayakan sesama pengguna.\n\n'
            '4. Fitur SOS darurat hanya boleh digunakan pada kondisi gawat darurat yang sesungguhnya.\n\n'
            '5. UBantu berhak menonaktifkan akun yang melanggar ketentuan komunitas.',
            style: AppTypography.body2.copyWith(
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Tutup',
              style: AppTypography.body1.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNext() async {
    if (_formKey.currentState?.validate() != true) return;

    final regProvider = context.read<RegistrationProvider>();
    regProvider.setAccountDetails(
      fullName: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    final nextStep = await regProvider.signUp();

    if (!mounted) return;

    if (regProvider.registeredUser != null) {
      context.read<AuthProvider>().updateUser(regProvider.registeredUser!);
    }

    if (nextStep.name == 'failed') {
      final errorMsg = (regProvider as dynamic).signUpError as String? ??
          'Registrasi gagal. Periksa kembali data Anda.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      case RegistrationNextStep.otpSkipped:
        await context.read<AuthProvider>().login(
              _emailController.text,
              _passwordController.text,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Layanan email sedang sibuk, verifikasi email dilewati sementara'),
              backgroundColor: AppColors.primaryDark,
            ),
          );
          CustomToast.show(
            context,
            message: 'Akun berhasil dibuat! Selamat datang.',
            type: ToastType.success,
          );
          context.go(AppRouter.home);
        }
        break;
      case RegistrationNextStep.ktmVerification:
        if (regProvider.emailOtpSkipped) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Layanan email sedang sibuk, verifikasi email dilewati sementara'),
              backgroundColor: AppColors.primaryDark,
            ),
          );
        }
        context.push(AppRouter.ktmVerification);
        break;
      case RegistrationNextStep.failed:
        break;
      case RegistrationNextStep.otpVerification:
        if (mounted) {
          context.go(AppRouter.otpVerification);
        }
        break;
    }
  }

  void _onGoogleSignUp() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      CustomToast.show(
        context,
        message: 'Selamat datang di Ubantu!',
        type: ToastType.success,
      );
      context.go(AppRouter.home);
    } else {
      final errorMsg = authProvider.errorMessage ?? 'Gagal mendaftar dengan Google.';
      CustomToast.show(
        context,
        message: errorMsg,
        type: ToastType.danger,
      );
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
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _agreedToTerms = val ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreedToTerms = !_agreedToTerms;
                          });
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'Saya menyetujui ',
                            style: AppTypography.body2.copyWith(
                              color: Colors.grey.shade700,
                            ),
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: _showTermsDialog,
                                  child: Text(
                                    'Syarat & Ketentuan',
                                    style: AppTypography.body2.copyWith(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' UBantu'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: regProvider.isSigningUp ? 'Mendaftarkan...' : 'Lanjutkan',
                  onPressed: (_agreedToTerms && !regProvider.isSigningUp) ? _onNext : null,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'atau',
                        style: AppTypography.body2.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onPressed: _onGoogleSignUp,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.g_mobiledata_rounded,
                          size: 28,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Daftar dengan google',
                          style: AppTypography.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
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
