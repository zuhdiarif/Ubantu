import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/custom_empty_state.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';

class MitraDashboardView extends StatefulWidget {
  const MitraDashboardView({super.key});

  @override
  State<MitraDashboardView> createState() => _MitraDashboardViewState();
}

class _MitraDashboardViewState extends State<MitraDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MitraProvider>().loadMitraData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MitraProvider>();
    final profile = provider.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        title: Text(
          'Dashboard Mitra UB',
          style: AppTypography.h5.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => provider.loadMitraData(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.push('/mitra/register'),
          ),
        ],
      ),
      body: provider.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.loadMitraData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMitraProfileCard(context, provider),
                    const SizedBox(height: 16),
                    _buildAvailabilitySwitch(context, provider),
                    const SizedBox(height: 16),
                    _buildStatsRow(context, provider),
                    const SizedBox(height: 20),
                    if (provider.activeOrder != null) ...[
                      _buildActiveOrderBanner(context, provider.activeOrder!),
                      const SizedBox(height: 20),
                    ],
                    _buildIncomingOrdersSection(context, provider),
                    const SizedBox(height: 24),
                    _buildQuickNavigationMenu(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMitraProfileCard(BuildContext context, MitraProvider provider) {
    final profile = provider.profile;
    final name = profile?.name ?? 'Ahmad Fauzi (Mitra UB)';
    final faculty =
        profile?.faculty ?? 'Fakultas Ilmu Komputer, Universitas Brawijaya';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primarySage,
            child: const Icon(
              Icons.engineering_rounded,
              color: AppColors.primaryDark,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: AppTypography.body1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 12, color: Colors.white),
                          SizedBox(width: 2),
                          Text(
                            'KTM OK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  faculty,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySwitch(
    BuildContext context,
    MitraProvider provider,
  ) {
    final isOnline = provider.isOnline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline
              ? AppColors.primaryGreen.withValues(alpha: 0.4)
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? AppColors.primaryGreen : Colors.grey,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnline
                        ? 'Status: Online (Siap Membantu)'
                        : 'Status: Offline (Istirahat)',
                    style: AppTypography.body2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isOnline
                          ? AppColors.primaryDark
                          : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    isOnline
                        ? 'Order masuk akan langsung diteruskan'
                        : 'Anda tidak menerima order baru',
                    style: AppTypography.caption.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch.adaptive(
            value: isOnline,
            activeTrackColor: AppColors.primaryGreen,
            onChanged: (val) => provider.toggleOnlineStatus(val),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, MitraProvider provider) {
    final profile = provider.profile;
    final rating = profile?.rating ?? 4.9;
    final points = profile?.totalBarterPoints ?? 180;
    final completed = profile?.totalOrdersCompleted ?? 42;
    final acceptance = profile?.acceptanceRate ?? 98.0;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.star_rounded,
            iconColor: Colors.amber,
            label: 'Rating',
            value: '$rating ★',
            onTap: () => context.push('/mitra/performance'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.token_rounded,
            iconColor: AppColors.accentOrange,
            label: 'Poin Barter',
            value: '$points Pts',
            onTap: () => context.push('/mitra/earnings'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.task_alt_rounded,
            iconColor: AppColors.primaryGreen,
            label: 'Selesai',
            value: '$completed',
            onTap: null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            context,
            icon: Icons.thumb_up_alt_rounded,
            iconColor: Colors.blueAccent,
            label: 'Penerimaan',
            value: '${acceptance.toInt()}%',
            onTap: null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.body2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.overline.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveOrderBanner(
    BuildContext context,
    ServiceOrderModel activeOrder,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.orangeLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.accentOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_run_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Order Sedang Berjalan',
                    style: AppTypography.body2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.orangeDarker,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activeOrder.status == MoveServiceStatus.accepted
                      ? 'Diterima'
                      : 'Sedang Proses',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Layanan ${activeOrder.category.name}: ${activeOrder.itemDescription}',
            style: AppTypography.body2.copyWith(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  activeOrder.locationDestination,
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.navigation_rounded, size: 18),
              label: const Text(
                'Kelola Order Aktif',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => context.push('/mitra/active-order'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingOrdersSection(
    BuildContext context,
    MitraProvider provider,
  ) {
    final orders = provider.incomingOrders;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Order Masuk',
                  style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySage,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            if (orders.isNotEmpty)
              Text(
                'Sedang Diambil (Belum Tuntas)',
                style: AppTypography.caption.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          const CustomEmptyState(
            icon: Icons.assignment_outlined,
            title: 'Belum Ada Order yang Diambil',
            message:
                'Pesanan baru muncul di tab "Membantu" pada Beranda utama. Ambil pesanan di sana untuk mulai membantu.',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(context, provider, order);
            },
          ),
      ],
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    MitraProvider provider,
    ServiceOrderModel order,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySage.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _categoryTitle(order.category),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(order.scheduledAt),
                    style: AppTypography.caption.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.itemDescription,
            style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.trip_origin_rounded,
                size: 16,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.locationOrigin,
                  style: AppTypography.body2.copyWith(
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 16,
                color: AppColors.accentOrange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.locationDestination,
                  style: AppTypography.body2.copyWith(
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.restaurant_rounded,
                  size: 16,
                  color: AppColors.accentOrange,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Imbalan Barter: ${order.barterDescription}',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.navigation_rounded, size: 18),
              label: const Text(
                'Kelola / Lanjutkan Bantuan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                provider.setActiveOrder(order);
                context.push('/mitra/active-order');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavigationMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Fitur Mitra',
          style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildNavTile(
          context,
          icon: Icons.account_balance_wallet_outlined,
          title: 'Dompet & Rekap Barter',
          subtitle: 'Lihat rekap harian/mingguan dan riwayat poin barter',
          route: '/mitra/earnings',
        ),
        _buildNavTile(
          context,
          icon: Icons.military_tech_outlined,
          title: 'Performa & Ulasan Mahasiswa',
          subtitle: 'Skor rating rata-rata, penyelesaian, dan ulasan pemesan',
          route: '/mitra/performance',
        ),
        _buildNavTile(
          context,
          icon: Icons.checklist_rtl_rounded,
          title: 'Kategori Layanan & Kendaraan',
          subtitle: 'Atur layanan yang Anda kuasai dan informasi kendaraan',
          route: '/mitra/register',
        ),
        _buildNavTile(
          context,
          icon: Icons.swap_horiz_rounded,
          title: 'Kembali ke Mode Mahasiswa',
          subtitle: 'Beralih ke tampilan beranda pencari bantuan',
          route: AppRouter.home,
        ),
      ],
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySage.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          title: Text(
            title,
            style: AppTypography.body2.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            subtitle,
            style: AppTypography.caption.copyWith(color: Colors.grey.shade600),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 20,
          ),
          onTap: () => context.push(route),
        ),
      ),
    );
  }

  String _categoryTitle(ServiceCategory cat) {
    switch (cat) {
      case ServiceCategory.pindahKos:
        return 'Pindah Kos';
      case ServiceCategory.bersihKos:
        return 'Bersih Kos';
      case ServiceCategory.antarJemput:
        return 'Antar Jemput / Tebengan';
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }
}
