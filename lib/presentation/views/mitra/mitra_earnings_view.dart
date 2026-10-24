import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/custom_empty_state.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/domain/models/mitra_earning_item_model.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';

class MitraEarningsView extends StatefulWidget {
  const MitraEarningsView({super.key});

  @override
  State<MitraEarningsView> createState() => _MitraEarningsViewState();
}

class _MitraEarningsViewState extends State<MitraEarningsView> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Semua', 'Harian', 'Mingguan'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MitraProvider>();
    final profile = provider.profile;
    final totalPoints = profile?.totalBarterPoints ?? 180;
    final earnings = provider.earningsHistory;

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
          'Dompet & Rekap Barter',
          style: AppTypography.h5.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWalletHeroCard(context, totalPoints),
            const SizedBox(height: 16),
            _buildTimeframeFilter(),
            const SizedBox(height: 16),
            _buildEarningsSummaryGrid(earnings.length, totalPoints),
            const SizedBox(height: 20),
            Text(
              'Rincian Transaksi Barter',
              style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (earnings.isEmpty)
              const CustomEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Belum Ada Transaksi',
                message:
                    'Selesaikan order pertama Anda untuk mulai mengumpulkan poin dan barter.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: earnings.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = earnings[index];
                  return _buildEarningCard(item);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletHeroCard(BuildContext context, int totalPoints) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, Color(0xFF3E523D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo Poin Barter UB',
                style: AppTypography.body2.copyWith(color: Colors.white70),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySage.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: AppColors.primarySage,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Terkunci Aman',
                      style: TextStyle(
                        color: AppColors.primarySage,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$totalPoints',
                style: AppTypography.display.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Poin Barter',
                style: AppTypography.h5.copyWith(color: AppColors.primarySage),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.primarySage,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Setiap bantuan yang diselesaikan memberikan imbalan barter fisik + 10 Poin reputasi loyalitas UB.',
                    style: AppTypography.caption.copyWith(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeFilter() {
    return Row(
      children: List.generate(_filters.length, (index) {
        final isSelected = _selectedFilterIndex == index;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(
              _filters[index],
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primaryDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primaryGreen,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
            ),
            onSelected: (val) {
              if (val) {
                setState(() => _selectedFilterIndex = index);
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildEarningsSummaryGrid(int count, int totalPoints) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.volunteer_activism_rounded,
                  color: AppColors.accentOrange,
                  size: 22,
                ),
                const SizedBox(height: 8),
                Text(
                  '$count Bantuan',
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'Order Berhasil',
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
                const SizedBox(height: 8),
                Text(
                  '+${count * 10} Pts',
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'Total Diperoleh',
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEarningCard(MitraEarningItemModel item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.orderNumber,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${item.pointsEarned} Poin',
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.serviceTitle,
            style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                item.customerName,
                style: AppTypography.caption.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(item.date),
                style: AppTypography.caption.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.restaurant_rounded,
                  size: 14,
                  color: AppColors.accentOrange,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Barter: ${item.barterDescription}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.orangeDarker,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
