import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/custom_button.dart';
import 'package:ubantu/components/custom_input_field.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/core/utils/app_validators.dart';
import 'package:ubantu/core/utils/input_formatters.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/presentation/providers/registration_provider.dart';

class KtmVerificationView extends StatefulWidget {
  const KtmVerificationView({super.key});

  @override
  State<KtmVerificationView> createState() => _KtmVerificationViewState();
}

class _KtmVerificationViewState extends State<KtmVerificationView> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();

  @override
  void dispose() {
    _nimController.dispose();
    super.dispose();
  }

  void _onVerify() async {
    if (_formKey.currentState?.validate() ?? false) {
      final regProvider = context.read<RegistrationProvider>();
      regProvider.setKtmData(nim: _nimController.text);
      regProvider.updateKtmStatus(KtmVerificationStatus.pending);

      await regProvider.sendOtp();
      if (mounted) {
        context.push(AppRouter.otpVerification);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Verifikasi KTM',
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
                  label: 'NIM',
                  placeholder: 'Contoh: 245150XXXXXXXXX',
                  controller: _nimController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [NimInputFormatter()],
                  validator: AppValidators.validateNim,
                ),
                const SizedBox(height: 20),
                Text(
                  'Foto KTM',
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '*Pastikan foto jelas dan tidak buram',
                  style: AppTypography.body2.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data kamu aman',
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hanya digunakan untuk verifikasi identitas mahasiswa Universitas Brawijaya',
                        style: AppTypography.body2.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                CustomButton(
                  text: 'Verifikasi & Kirim OTP',
                  onPressed: _onVerify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
