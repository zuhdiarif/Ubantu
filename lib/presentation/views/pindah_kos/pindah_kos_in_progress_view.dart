import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';

class PindahKosInProgressView extends StatelessWidget {
  const PindahKosInProgressView({super.key});

  static const List<String> _stages = [
    'Mitra berangkat menuju lokasi asal',
    'Mitra tiba di lokasi asal',
    'Proses packing & muat barang',
    'Dalam perjalanan ke lokasi tujuan',
    'Barang tiba & selesai',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E281C)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Bantuan Berlangsung',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E281C),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelperCard(),
            const SizedBox(height: 24),
            _buildProgressSection(),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHelperCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EBE4)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFE2F1D8),
            child: Icon(
              Icons.person_rounded,
              size: 36,
              color: Color(0xFF283626),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ahmad Rizki',
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E281C),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.9 (32 ulasan)',
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF5C6658),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Mitra Terverifikasi UB',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF283626),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progres Bantuan',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E281C),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_stages.length, (idx) {
          final isDone = idx < 2;
          final isCurrent = idx == 2;
          return _buildStageItem(
            label: _stages[idx],
            isDone: isDone,
            isCurrent: isCurrent,
            isLast: idx == _stages.length - 1,
          );
        }),
      ],
    );
  }

  Widget _buildStageItem({
    required String label,
    required bool isDone,
    required bool isCurrent,
    required bool isLast,
  }) {
    final Color dotColor = isDone
        ? const Color(0xFF283626)
        : isCurrent
            ? const Color(0xFF4CAF50)
            : const Color(0xFFCDD3C8);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
              child: isDone
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : isCurrent
                      ? const Icon(
                          Icons.radio_button_checked_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone
                    ? const Color(0xFF283626)
                    : const Color(0xFFE8EBE4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: AppTypography.body2.copyWith(
                color: isDone || isCurrent
                    ? const Color(0xFF1E281C)
                    : const Color(0xFF9E9E9E),
                fontWeight:
                    isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push(AppRouter.sosForm),
            icon: const Icon(Icons.emergency_rounded, color: Colors.red),
            label: Text(
              'SOS',
              style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat_rounded),
            label: Text(
              'Chat',
              style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF283626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
