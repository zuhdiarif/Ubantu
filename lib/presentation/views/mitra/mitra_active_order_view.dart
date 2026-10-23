import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';

class MitraActiveOrderView extends StatelessWidget {
  const MitraActiveOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MitraProvider>();
    final activeOrder = provider.activeOrder;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Kelola Order Aktif',
          style: AppTypography.h5.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
            tooltip: 'Bantuan Darurat SOS',
            onPressed: () => _showSosDialog(context),
          ),
        ],
      ),
      body: activeOrder == null
          ? _buildNoActiveOrder(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusStepper(context, activeOrder.status),
                  const SizedBox(height: 16),
                  _buildCustomerContactCard(context, activeOrder),
                  const SizedBox(height: 16),
                  _buildOrderDetailsCard(context, activeOrder),
                  const SizedBox(height: 16),
                  _buildBarterAgreementCard(context, activeOrder),
                  const SizedBox(height: 24),
                  _buildActionControls(context, provider, activeOrder),
                ],
              ),
            ),
    );
  }

  Widget _buildNoActiveOrder(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 64,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Order Aktif',
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua order yang Anda terima telah selesai. Kembali ke dashboard untuk melihat order masuk lainnya.',
              textAlign: TextAlign.center,
              style:
                  AppTypography.body2.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => context.pop(),
              child: const Text('Kembali ke Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStepper(BuildContext context, MoveServiceStatus status) {
    int currentStep = 0;
    if (status == MoveServiceStatus.accepted) {
      currentStep = 1;
    } else if (status == MoveServiceStatus.inProgress) {
      currentStep = 2;
    } else if (status == MoveServiceStatus.completed) {
      currentStep = 3;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tahapan Pelaksanaan',
                style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySage.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Langkah $currentStep dari 3',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStepItem(
                title: 'Diterima',
                isDone: currentStep >= 1,
                isActive: currentStep == 1,
              ),
              _buildStepConnector(isDone: currentStep >= 2),
              _buildStepItem(
                title: 'Menuju Lokasi',
                isDone: currentStep >= 2,
                isActive: currentStep == 2,
              ),
              _buildStepConnector(isDone: currentStep >= 3),
              _buildStepItem(
                title: 'Selesai',
                isDone: currentStep >= 3,
                isActive: currentStep == 3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String title,
    required bool isDone,
    required bool isActive,
  }) {
    Color bg = Colors.grey.shade300;
    Color fg = Colors.grey.shade700;
    if (isDone) {
      bg = AppColors.primaryGreen;
      fg = Colors.white;
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '•',
                      style: TextStyle(
                        color: fg,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.primaryDark : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector({required bool isDone}) {
    return Container(
      width: 32,
      height: 3,
      margin: const EdgeInsets.only(bottom: 18),
      color: isDone ? AppColors.primaryGreen : Colors.grey.shade300,
    );
  }

  Widget _buildCustomerContactCard(
    BuildContext context,
    ServiceOrderModel order,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primarySage.withValues(alpha: 0.4),
            child: const Icon(Icons.person, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pemesan Layanan',
                  style: AppTypography.overline.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Mahasiswa UB (Pemesan)',
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Terverifikasi KTM Brawijaya',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: const Text('Chat'),
            onPressed: () {
              context.push(
                AppRouter.chatRoom,
                extra: {
                  'roomId': 'room_active_${order.id}',
                  'otherUserName': 'Mahasiswa UB (Pemesan)',
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(
    BuildContext context,
    ServiceOrderModel order,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Tugas & Rute',
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.category_rounded,
            iconColor: AppColors.primaryGreen,
            label: 'Kategori',
            value: 'Layanan ${order.category.name}',
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            icon: Icons.description_outlined,
            iconColor: AppColors.primaryDark,
            label: 'Deskripsi Barang/Tugas',
            value: order.itemDescription,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            icon: Icons.trip_origin_rounded,
            iconColor: AppColors.primaryGreen,
            label: 'Lokasi Asal',
            value: order.locationOrigin,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.accentOrange,
            label: 'Lokasi Tujuan',
            value: order.locationDestination,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarterAgreementCard(
    BuildContext context,
    ServiceOrderModel order,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.orangeLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentOrange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kesepakatan Imbalan Barter',
                  style: AppTypography.overline.copyWith(
                    color: AppColors.orangeDarker,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.barterDescription,
                  style: AppTypography.body2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  '+10 Poin Barter akan masuk ke dompet Anda saat selesai.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.orangeDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionControls(
    BuildContext context,
    MitraProvider provider,
    ServiceOrderModel order,
  ) {
    final status = order.status;
    String buttonText = 'Mulai Menuju Lokasi';
    IconData buttonIcon = Icons.two_wheeler_rounded;
    Color buttonColor = AppColors.primaryGreen;

    if (status == MoveServiceStatus.inProgress) {
      buttonText = 'Selesaikan Bantuan & Terima Barter';
      buttonIcon = Icons.check_circle_rounded;
      buttonColor = AppColors.primaryDark;
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(buttonIcon, size: 20),
            label: Text(
              buttonText,
              style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              if (status == MoveServiceStatus.accepted) {
                await provider.advanceActiveOrderStatus();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Status diperbarui: Sedang Menuju Lokasi Pemesan',
                      ),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                }
              } else if (status == MoveServiceStatus.inProgress) {
                final success = await provider.advanceActiveOrderStatus();
                if (success && context.mounted) {
                  _showCompletionDialog(context);
                }
              }
            },
          ),
        ),
      ],
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            const Icon(
              Icons.stars_rounded,
              size: 56,
              color: AppColors.accentOrange,
            ),
            const SizedBox(height: 10),
            Text(
              'Bantuan Selesai!',
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Terima kasih atas bantuan Anda! Imbalan barter telah diserahkan dan saldo dompet barter Anda bertambah +10 Poin.',
          textAlign: TextAlign.center,
          style: AppTypography.body2,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pop();
              },
              child: const Text('Kembali ke Dashboard'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Bantuan Darurat SOS'),
          ],
        ),
        content: const Text(
          'Apakah Anda memerlukan bantuan darurat keamanan selama proses bantuan ini? '
          'Sinyal darurat beserta koordinat Anda akan segera diteruskan ke Satpam Kampus UB.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sinyal SOS Mitra telah dikirim ke Satpam UB!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Kirim SOS Sekarang'),
          ),
        ],
      ),
    );
  }
}
