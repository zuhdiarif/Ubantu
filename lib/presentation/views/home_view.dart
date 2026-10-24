import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';
import 'package:ubantu/presentation/providers/task_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _modeTab = 0;
  int _activityTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceOrderProvider>().loadActiveOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Material(
      color: AppColors.background,
      child: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildModeToggle(taskProvider),
              const SizedBox(height: 20),
              if (_modeTab == 0) ...[
                _buildPromoBanner(),
                const SizedBox(height: 24),
                _buildLayananPopulerSection(),
                const SizedBox(height: 24),
                _buildAktivitasSayaSection(),
              ] else ...[
                _buildOrangButuhBantuanSection(taskProvider),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 26,
          backgroundColor: Color(0xFFE2F1D8),
          backgroundImage: AssetImage('assets/images/img_avatar_farel.png'),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hai Farel!',
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E281C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Mau bantu apa hari ini?',
                style: AppTypography.body2.copyWith(
                  color: const Color(0xFF5C6658),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE3E7DE)),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF1E281C),
              size: 22,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle(TaskProvider taskProvider) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7E2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _modeTab = 0;
                });
                taskProvider.switchMode(0);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _modeTab == 0 ? const Color(0xFF283626) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Butuh Bantuan',
                  style: AppTypography.body2.copyWith(
                    fontWeight: _modeTab == 0 ? FontWeight.bold : FontWeight.w500,
                    color: _modeTab == 0 ? Colors.white : const Color(0xFF283626),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _modeTab = 1;
                });
                taskProvider.switchMode(1);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _modeTab == 1 ? const Color(0xFF283626) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Membantu',
                  style: AppTypography.body2.copyWith(
                    fontWeight: _modeTab == 1 ? FontWeight.bold : FontWeight.w500,
                    color: _modeTab == 1 ? Colors.white : const Color(0xFF283626),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF283626),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bantu bareng,\nringankan beban!',
                  style: AppTypography.h5.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'UBantu hadir untuk membantu mahasiswa',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF283626),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Lihat Promo',
                    style: AppTypography.body2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF283626),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Image.asset(
              'assets/images/img_promo_helper.png',
              height: 110,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayananPopulerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Layanan Populer',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E281C),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => context.push(AppRouter.bersihKos),
                child: _buildCategoryCard(
                  title: 'Bersih kos',
                  imageAsset: 'assets/images/ic_bersih_kos.png',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => context.push(AppRouter.pindahKos),
                child: _buildCategoryCard(
                  title: 'Pindah kos',
                  imageAsset: 'assets/images/ic_pindah_kos.png',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => context.push(AppRouter.antarJemput),
                child: _buildCategoryCard(
                  title: 'Antar jemput',
                  imageAsset: 'assets/images/ic_antar_jemput.png',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String imageAsset,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
      child: Column(
        children: [
          Image.asset(
            imageAsset,
            height: 64,
            width: 64,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E281C),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAktivitasSayaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitas saya',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E281C),
          ),
        ),
        const SizedBox(height: 14),
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
                      _activityTab = 0;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _activityTab == 0 ? const Color(0xFF283626) : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Sedang berlangsung',
                      style: AppTypography.body2.copyWith(
                        fontWeight: _activityTab == 0 ? FontWeight.bold : FontWeight.w500,
                        color: _activityTab == 0 ? Colors.white : const Color(0xFF283626),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activityTab = 1;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _activityTab == 1 ? const Color(0xFF283626) : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Histori',
                      style: AppTypography.body2.copyWith(
                        fontWeight: _activityTab == 1 ? FontWeight.bold : FontWeight.w500,
                        color: _activityTab == 1 ? Colors.white : const Color(0xFF283626),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildAktivitasCard(
          title: 'Bersih kos',
          location: 'Jl.Veteran, Malang',
          dateTime: '20 Juli 2026 - 09:00',
          imageAsset: 'assets/images/ic_bersih_kos.png',
          statusText: 'Berlangsung',
        ),
      ],
    );
  }

  Widget _buildAktivitasCard({
    required String title,
    required String location,
    required String dateTime,
    required String imageAsset,
    required String statusText,
  }) {
    return Container(
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
                    const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF283626)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
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
                    const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF283626)),
                    const SizedBox(width: 4),
                    Text(
                      dateTime,
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
              color: const Color(0xFFE2F1D8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: AppTypography.caption.copyWith(
                color: const Color(0xFF283626),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrangButuhBantuanSection(TaskProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF283626),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFA8C686),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.engineering_rounded,
                  color: Color(0xFF283626),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Mitra Jasa UB',
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kelola ketersediaan online, terima order & kumpulkan barter.',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA8C686),
                  foregroundColor: const Color(0xFF283626),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => context.push(AppRouter.mitraDashboard),
                child: const Text(
                  'Buka',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Text(
          'Orang yang Butuh Bantuan',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E281C),
          ),
        ),
        const SizedBox(height: 14),
        ..._buildOrderList(context, provider),
      ],
    );
  }

  List<Widget> _buildOrderList(BuildContext context, TaskProvider taskProvider) {
    final orderProvider = context.watch<ServiceOrderProvider>();
    final orders = orderProvider.activeOrders;

    if (orders.isNotEmpty) {
      return orders.map((order) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EBE4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFE2F1D8),
                    child: Icon(
                      _getCategoryIcon(order.category),
                      color: const Color(0xFF283626),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2F1D8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getCategoryName(order.category),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF283626),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Menunggu Bantuan',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFF86B049),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.itemDescription,
                          style: AppTypography.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E281C),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showOrderHelpDialog(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF283626),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Bantu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Color(0xFF5C6658),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${order.locationOrigin} → ${order.locationDestination}',
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF5C6658),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (order.barterDescription.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard_rounded,
                      size: 14,
                      color: AppColors.accentOrange,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Barter: ${order.barterDescription}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      }).toList();
    }

    if (taskProvider.tasks.isNotEmpty) {
      return taskProvider.tasks.map((task) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EBE4)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFE2F1D8),
                child: Icon(Icons.person_rounded, color: Color(0xFF283626)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E281C),
                      ),
                    ),
                    Text(
                      'Oleh: ${task.requesterName}',
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF5C6658),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => context.push(AppRouter.helpDetail),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF283626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Bantu'),
              ),
            ],
          ),
        );
      }).toList();
    }

    return [
      Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.volunteer_activism_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Belum Ada yang Butuh Bantuan',
              style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Tarik ke bawah untuk memperbarui daftar permintaan bantuan.',
              style: AppTypography.caption.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ];
  }

  void _showOrderHelpDialog(ServiceOrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Detail Permintaan Bantuan',
              style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Layanan', _getCategoryName(order.category)),
            _buildDetailRow('Keterangan', order.itemDescription),
            _buildDetailRow('Lokasi Penjemputan', order.locationOrigin),
            _buildDetailRow('Lokasi Tujuan', order.locationDestination),
            _buildDetailRow('Imbalan Barter', order.barterDescription),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF283626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final nav = Navigator.of(sheetContext);
                  final orderProv = context.read<ServiceOrderProvider>();
                  final mitraProv = context.read<MitraProvider>();
                  nav.pop();
                  final success = await orderProv.acceptOrder(order.id);
                  if (success) {
                    await mitraProv.acceptOrder(order.id);
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Bantuan berhasil diambil! Menuju ke halaman order aktif.',
                        ),
                        backgroundColor: Color(0xFF283626),
                      ),
                    );
                    if (mounted) {
                      context.push('/mitra/active-order');
                    }
                  }
                },
                child: const Text(
                  'Ambil Bantuan Ini',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body2.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(ServiceCategory cat) {
    switch (cat) {
      case ServiceCategory.pindahKos:
        return 'Pindah Kos';
      case ServiceCategory.bersihKos:
        return 'Bersih Kos';
      case ServiceCategory.antarJemput:
        return 'Antar Jemput';
    }
  }

  IconData _getCategoryIcon(ServiceCategory cat) {
    switch (cat) {
      case ServiceCategory.pindahKos:
        return Icons.local_shipping_rounded;
      case ServiceCategory.bersihKos:
        return Icons.cleaning_services_rounded;
      case ServiceCategory.antarJemput:
        return Icons.two_wheeler_rounded;
    }
  }
}
