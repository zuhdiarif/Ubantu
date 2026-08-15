import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ubantu/components/custom_button.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';

class SosFinishDialogView extends StatelessWidget {
  const SosFinishDialogView({super.key});

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
          'Penyelesaian SOS',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  size: 60,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Apakah laporan sudah selesai?',
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Jika masalah sudah terselesaikan dan kamu tidak membutuhkan bantuan lebih lanjut, silakan akhiri laporan ini.',
                textAlign: TextAlign.center,
                style: AppTypography.body1.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 36),
              CustomButton(
                text: 'Selesai',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () => context.go(AppRouter.home),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Lapor Kembali',
                type: CustomButtonType.dangerOutline,
                icon: Icons.refresh_rounded,
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Keamanan kamu adalah prioritas kami. Jangan ragu untuk laporan kembali jika diperlukan.',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
