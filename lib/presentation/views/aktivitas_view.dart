import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/custom_empty_state.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

class AktivitasView extends StatefulWidget {
  const AktivitasView({super.key});

  @override
  State<AktivitasView> createState() => _AktivitasViewState();
}

class _AktivitasViewState extends State<AktivitasView> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id ?? '';
    context.read<ServiceOrderProvider>().loadMyOrders(userId);
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<ServiceOrderProvider>();
    final myOrders = orderProvider.myOrders;

    final ongoingOrders = myOrders
        .where((o) => o.status != MoveServiceStatus.completed)
        .toList();

    final historyOrders = myOrders
        .where((o) => o.status == MoveServiceStatus.completed)
        .toList();

    final displayedOrders = _selectedTab == 0 ? ongoingOrders : historyOrders;

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aktivitas Saya',
                  style: AppTypography.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E281C),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7E2),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab = 0;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedTab == 0
                                  ? const Color(0xFF283626)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Sedang Berlangsung',
                              style: AppTypography.body2.copyWith(
                                fontWeight: _selectedTab == 0
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: _selectedTab == 0
                                    ? Colors.white
                                    : const Color(0xFF283626),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab = 1;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedTab == 1
                                  ? const Color(0xFF283626)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Histori Selesai',
                              style: AppTypography.body2.copyWith(
                                fontWeight: _selectedTab == 1
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: _selectedTab == 1
                                    ? Colors.white
                                    : const Color(0xFF283626),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (displayedOrders.isEmpty)
                  CustomEmptyState(
                    icon: _selectedTab == 0
                        ? Icons.pending_actions_rounded
                        : Icons.history_rounded,
                    title: _selectedTab == 0
                        ? 'Belum Ada Pesanan Aktif'
                        : 'Belum Ada Riwayat Pesanan',
                    message: _selectedTab == 0
                        ? 'Pesanan bantuan yang sedang berjalan akan ditampilkan di sini.'
                        : 'Pesanan bantuan yang telah diselesaikan akan tercatat di sini.',
                  )
                else
                  ...displayedOrders.map((order) => _buildOrderCard(order)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(ServiceOrderModel order) {
    final title = switch (order.category) {
      ServiceCategory.pindahKos => 'Pindah kos',
      ServiceCategory.bersihKos => 'Bersih kos',
      ServiceCategory.antarJemput => 'Antar jemput',
    };

    final imageAsset = switch (order.category) {
      ServiceCategory.pindahKos => 'assets/images/ic_pindah_kos.png',
      ServiceCategory.bersihKos => 'assets/images/ic_bersih_kos.png',
      ServiceCategory.antarJemput => 'assets/images/ic_antar_jemput.png',
    };

    final statusText = switch (order.status) {
      MoveServiceStatus.waiting => 'Menunggu',
      MoveServiceStatus.accepted => 'Diterima',
      MoveServiceStatus.inProgress => 'Berlangsung',
      MoveServiceStatus.completed => 'Selesai',
      MoveServiceStatus.cancelled => 'Batal',
    };

    final isOngoing = order.status != MoveServiceStatus.completed;

    final dateStr =
        '${order.scheduledAt.day} ${_monthName(order.scheduledAt.month)} ${order.scheduledAt.year} - ${order.scheduledAt.hour.toString().padLeft(2, '0')}:${order.scheduledAt.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () {
        context.push(AppRouter.bantuanDetail, extra: order);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EBE4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F4EC),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  imageAsset,
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E281C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: Color(0xFF283626),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.locationOrigin,
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF5C6658),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: Color(0xFF283626),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFF5C6658),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isOngoing
                    ? const Color(0xFFE2F1D8)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: AppTypography.caption.copyWith(
                  color: isOngoing
                      ? const Color(0xFF283626)
                      : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }
}
