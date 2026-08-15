import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ubantu/components/custom_badge.dart';
import 'package:ubantu/components/custom_button.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';

class HelpDetailView extends StatelessWidget {
  const HelpDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Bantuan Berlangsung',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status: Aktif',
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Informasi Pengguna',
                style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primarySage,
                    child: Text(
                      'D',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dinda Putri',
                        style: AppTypography.h5.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.6 (18)',
                            style: AppTypography.body2.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Bantuan',
                      style: AppTypography.h5.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      label: 'Jenis Layanan',
                      child: const CustomBadge(
                        text: 'Bersih Kos',
                        type: BadgeType.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      label: 'Lokasi',
                      icon: Icons.location_on_outlined,
                      text: 'Jl. Kaliurang Km 5, Yogyakarta',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      label: 'Tanggal & Jam',
                      icon: Icons.calendar_today_outlined,
                      text: '2 Jun 2025 • 10:00',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      label: 'Catatan',
                      icon: Icons.chat_bubble_outline_rounded,
                      text: 'Bantu bersihkan kamar kos, alat sudah disiapkan.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 40,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Lihat di Peta',
                              style: AppTypography.body2.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.open_in_new_rounded, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Chat',
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Bantuan (SOS)',
                type: CustomButtonType.dangerOutline,
                icon: Icons.warning_amber_rounded,
                onPressed: () => context.push(AppRouter.sosForm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    Widget? child,
    IconData? icon,
    String? text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: AppTypography.body2.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        if (child != null) ...[child],
        if (text != null) ...[
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.primaryDark),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              text,
              style: AppTypography.body2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
