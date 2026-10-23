import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

class PindahKosView extends StatefulWidget {
  const PindahKosView({super.key});

  @override
  State<PindahKosView> createState() => _PindahKosViewState();
}

class _PindahKosViewState extends State<PindahKosView> {
  int _bannerIndex = 0;

  final List<Map<String, String>> _banners = [
    {
      'title': 'Pindah Kos Mudah!',
      'subtitle': 'Dibantu sesama mahasiswa UB',
    },
    {
      'title': 'Barter Makanan & Barang',
      'subtitle': 'Tidak perlu uang, cukup barter',
    },
    {
      'title': 'Aman & Terpercaya',
      'subtitle': 'Semua mitra terverifikasi KTM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceOrderProvider>();
    final activeOrder = provider.myOrders.where(
      (o) =>
          o.category == ServiceCategory.pindahKos &&
          (o.status == MoveServiceStatus.waiting ||
              o.status == MoveServiceStatus.accepted ||
              o.status == MoveServiceStatus.inProgress),
    );

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
          'Pindah Kos',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E281C),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF1E281C),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerCarousel(),
            const SizedBox(height: 24),
            _buildRequestButton(context),
            if (activeOrder.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildActiveOrderSection(context, activeOrder.first),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            itemCount: _banners.length,
            onPageChanged: (idx) => setState(() => _bannerIndex = idx),
            itemBuilder: (context, idx) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF283626),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _banners[idx]['title']!,
                      style: AppTypography.h5.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _banners[idx]['subtitle']!,
                      style: AppTypography.body2.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (idx) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _bannerIndex == idx ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _bannerIndex == idx
                    ? const Color(0xFF283626)
                    : const Color(0xFFCDD3C8),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.push(AppRouter.pindahKosForm),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Meminta Bantuan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF283626),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTypography.body1.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOrderSection(
    BuildContext context,
    serviceOrderModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitas Aktif',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E281C),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EBE4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F4EC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: Color(0xFF283626),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pindah Kos',
                          style: AppTypography.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E281C),
                          ),
                        ),
                        Text(
                          serviceOrderModel.locationOrigin,
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF5C6658),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F1D8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      serviceOrderModel.status == MoveServiceStatus.waiting
                          ? 'Menunggu'
                          : serviceOrderModel.status ==
                                  MoveServiceStatus.accepted
                              ? 'Diterima'
                              : 'Berlangsung',
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF283626),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    if (serviceOrderModel.status == MoveServiceStatus.waiting) {
                      context.push(AppRouter.pindahKosWaiting);
                    } else {
                      context.push(AppRouter.pindahKosInProgress);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF283626),
                    side: const BorderSide(color: Color(0xFF283626)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Lihat Detail'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
