import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/custom_button.dart';
import 'package:ubantu/components/custom_toast.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/presentation/providers/sos_provider.dart';

class SosFormView extends StatelessWidget {
  const SosFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final sosProvider = context.watch<SosProvider>();

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
          'Konfirmasi SOS',
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
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  size: 48,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Butuh bantuan?',
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih jenis bantuan yang sesuai dengan situasi yang kamu alami.',
                textAlign: TextAlign.center,
                style: AppTypography.body1.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              _buildRadioOption(
                context,
                index: 0,
                title: 'Merasa tidak aman',
                subtitle: 'Saya merasa terancam atau tidak nyaman dengan situasi ini.',
                icon: Icons.shield_outlined,
                selectedIndex: sosProvider.selectedReasonIndex,
              ),
              const SizedBox(height: 12),
              _buildRadioOption(
                context,
                index: 1,
                title: 'Terjadi masalah dengan pengguna lain',
                subtitle: 'Saya mengalami masalah atau konflik dengan pengguna.',
                icon: Icons.people_outline_rounded,
                selectedIndex: sosProvider.selectedReasonIndex,
              ),
              const SizedBox(height: 12),
              _buildRadioOption(
                context,
                index: 2,
                title: 'Kondisi darurat lainnya',
                subtitle: 'Situasi darurat lainnya yang membutuhkan bantuan segera.',
                icon: Icons.medical_services_outlined,
                selectedIndex: sosProvider.selectedReasonIndex,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tim kami akan segera merespon laporan kamu dan menghubungi dalam waktu tercepat.',
                        style: AppTypography.body2.copyWith(
                          color: const Color(0xFFC62828),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Kirim Bantuan',
                type: CustomButtonType.danger,
                icon: Icons.send_rounded,
                onPressed: () {
                  context.read<SosProvider>().updateStatus(SosStatus.received);
                  CustomToast.show(
                    context,
                    message: 'Laporan SOS berhasil dikirim! Tim sedang merespon.',
                    type: ToastType.danger,
                  );
                  context.push(AppRouter.sosActive);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(
    BuildContext context, {
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required int selectedIndex,
  }) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        context.read<SosProvider>().selectReason(index);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primaryGreen : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.body2.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
