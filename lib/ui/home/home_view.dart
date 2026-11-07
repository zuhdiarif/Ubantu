import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/ui/widgets/custom_avatar.dart';
import 'package:ubantu/core/theme/app_colors.dart';
import 'package:ubantu/core/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/service_order_model.dart';
import 'package:ubantu/data/models/user_model.dart';
import 'package:ubantu/ui/auth/auth_provider.dart';
import 'package:ubantu/ui/mitra/mitra_provider.dart';
import 'package:ubantu/ui/notification/notification_provider.dart';
import 'package:ubantu/ui/aktivitas/service_order_provider.dart';
import 'package:ubantu/ui/home/task_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  int _modeTab = 0;
  int _activityTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    final userId = user?.id ?? '';
    await Future.wait([
      context.read<ServiceOrderProvider>().loadActiveOrders(),
      context.read<TaskProvider>().loadTasks(),
      if (userId.isNotEmpty)
        context.read<ServiceOrderProvider>().loadMyOrders(userId),
      authProvider.refreshProfile(),
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_sos_fab',
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        tooltip: 'Darurat SOS',
        onPressed: () => context.push(AppRouter.sosForm),
        child: const Icon(
          Icons.emergency_rounded,
          size: 30,
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user),
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
      ),
    );
  }

  Widget _buildHeader(UserModel? user) {
    final rawName = user != null && user.fullName.isNotEmpty
        ? user.fullName.split(' ').first
        : 'Mahasiswa';
    final displayName = rawName.isNotEmpty
        ? rawName[0].toUpperCase() + rawName.substring(1)
        : 'Mahasiswa';

    return Row(
      children: [
        CustomAvatar(
          name: user?.fullName.isNotEmpty == true ? user!.fullName : displayName,
          imageUrl: user?.avatarUrl,
          radius: 26,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hai $displayName!',
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
        Builder(
          builder: (context) {
            NotificationProvider? notifProvider;
            try {
              notifProvider = Provider.of<NotificationProvider>(context, listen: true);
            } catch (_) {}
            final unreadCount = notifProvider?.unreadCount ?? 0;
            return Stack(
              clipBehavior: Clip.none,
              children: [
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
                    onPressed: () => context.push(AppRouter.notificationHistory),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        shape: unreadCount > 9 ? BoxShape.rectangle : BoxShape.circle,
                        borderRadius: unreadCount > 9 ? BorderRadius.circular(10) : null,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
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
                context.read<ServiceOrderProvider>().loadActiveOrders();
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
                  onPressed: () => _showPromoSheet(context),
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
    final orderProvider = context.watch<ServiceOrderProvider>();
    final myOrders = orderProvider.myOrders;
    final ongoingOrders = myOrders
        .where((o) =>
            o.status != MoveServiceStatus.completed &&
            o.status != MoveServiceStatus.cancelled &&
            o.status != MoveServiceStatus.dibatalkan)
        .toList();
    final historyOrders = myOrders
        .where((o) =>
            o.status == MoveServiceStatus.completed ||
            o.status == MoveServiceStatus.cancelled ||
            o.status == MoveServiceStatus.dibatalkan)
        .toList();

    final displayedOrders = _activityTab == 0 ? ongoingOrders : historyOrders;

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
        if (displayedOrders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8EBE4)),
            ),
            child: Column(
              children: [
                Icon(
                  _activityTab == 0
                      ? Icons.pending_actions_rounded
                      : Icons.history_rounded,
                  size: 36,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  _activityTab == 0
                      ? 'Belum ada aktivitas berlangsung'
                      : 'Belum ada riwayat pesanan',
                  style: AppTypography.body2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5C6658),
                  ),
                ),
              ],
            ),
          )
        else
          ...displayedOrders.map((order) => _buildAktivitasOrderCard(order)),
      ],
    );
  }

  Widget _buildAktivitasOrderCard(ServiceOrderModel order) {
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

    final dateStr =
        '${order.scheduledAt.day} ${_monthName(order.scheduledAt.month)} ${order.scheduledAt.year} - ${order.scheduledAt.hour.toString().padLeft(2, '0')}:${order.scheduledAt.minute.toString().padLeft(2, '0')}';

    final isCancelled = order.status == MoveServiceStatus.cancelled ||
        order.status == MoveServiceStatus.dibatalkan;
    final statusText = isCancelled ? 'Dibatalkan' : order.status.label;
    final badgeBg = isCancelled ? const Color(0xFFFFEBEE) : order.status.badgeBgColor;
    final badgeText = isCancelled ? const Color(0xFFC62828) : order.status.badgeTextColor;

    return GestureDetector(
      onTap: () {
        context.read<ServiceOrderProvider>().setActiveOrder(order);
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
                color: badgeBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: AppTypography.caption.copyWith(
                  color: badgeText,
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
        Row(
          children: [
            Expanded(
              child: Text(
                'Orang yang Butuh Bantuan',
                style: AppTypography.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E281C),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            FilterChip(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              avatar: Icon(
                Icons.female_rounded,
                size: 14,
                color: provider.isFemaleOnlyFilter ? Colors.white : const Color(0xFFC2185B),
              ),
              label: const Text('Women-Only'),
              labelStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: provider.isFemaleOnlyFilter ? Colors.white : const Color(0xFFC2185B),
              ),
              selected: provider.isFemaleOnlyFilter,
              selectedColor: const Color(0xFFC2185B),
              backgroundColor: const Color(0xFFFCE4EC),
              checkmarkColor: Colors.white,
              onSelected: (_) => provider.toggleFemaleOnlyFilter(),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._buildOrderList(context, provider),
      ],
    );
  }

  List<Widget> _buildOrderList(BuildContext context, TaskProvider taskProvider) {
    final authProvider = context.watch<AuthProvider>();
    final isMale = authProvider.currentUser?.gender == UserGender.male;
    final orderProvider = context.watch<ServiceOrderProvider>();
    final allOrders = orderProvider.activeOrders;
    var orders = isMale
        ? allOrders.where((o) => !o.isFemaleOnly).toList()
        : allOrders;
    if (taskProvider.isFemaleOnlyFilter) {
      orders = orders.where((o) => o.isFemaleOnly).toList();
    }

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
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
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
                            if (order.isFemaleOnly)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFCE4EC),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.female_rounded, size: 10, color: Color(0xFFC2185B)),
                                    SizedBox(width: 2),
                                    Text(
                                      'Khusus Mahasiswi',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFC2185B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Color(0xFF86B049),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '~${_estimateDistance(order)} km',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF86B049),
                        ),
                      ),
                    ],
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

    var tasks = isMale
        ? taskProvider.tasks.where((t) => !t.isFemaleOnly).toList()
        : taskProvider.tasks;
    if (taskProvider.isFemaleOnlyFilter) {
      tasks = tasks.where((t) => t.isFemaleOnly).toList();
    }

    if (tasks.isNotEmpty) {
      return tasks.map((task) {
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
                    if (task.isFemaleOnly) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCE4EC),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.female_rounded, size: 10, color: Color(0xFFC2185B)),
                                SizedBox(width: 2),
                                Text(
                                  'Khusus Mahasiswi',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC2185B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => context.push(AppRouter.helpDetail, extra: task),
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
            Icon(
              taskProvider.isFemaleOnlyFilter ? Icons.female_rounded : Icons.volunteer_activism_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              taskProvider.isFemaleOnlyFilter
                  ? 'Tidak Ada Bantuan Khusus Mahasiswi'
                  : 'Belum Ada yang Butuh Bantuan',
              style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              taskProvider.isFemaleOnlyFilter
                  ? 'Coba matikan filter untuk melihat seluruh permintaan bantuan.'
                  : 'Tarik ke bawah untuk memperbarui daftar permintaan bantuan.',
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
                  final mitraSuccess = await mitraProv.acceptOrder(order.id);
                  if (mitraSuccess) {
                    await orderProv.loadActiveOrders();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Bantuan berhasil diambil! Menuju ke halaman order aktif.',
                        ),
                        backgroundColor: Color(0xFF283626),
                      ),
                    );
                    if (mounted) {
                      context.push(AppRouter.mitraDashboard);
                    }
                  } else {
                    final fallbackSuccess = await orderProv.acceptOrder(order.id);
                    if (fallbackSuccess) {
                      await orderProv.loadActiveOrders();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Bantuan berhasil diambil! Menuju ke halaman order aktif.',
                          ),
                          backgroundColor: Color(0xFF283626),
                        ),
                      );
                      if (mounted) {
                        context.push(AppRouter.mitraDashboard);
                      }
                    } else {
                      final errorMsg = mitraProv.errorMessage ??
                          orderProv.errorMessage ??
                          'Gagal mengambil bantuan.';
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(errorMsg),
                          backgroundColor: const Color(0xFFD32F2F),
                        ),
                      );
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

  String _estimateDistance(ServiceOrderModel order) {
    if (order.locationOrigin.isEmpty && order.id.isEmpty) {
      return '1.2';
    }
    final seed = (order.id.isNotEmpty ? order.id : order.locationOrigin).hashCode.abs();
    final km = 0.5 + (seed % 26) / 10.0;
    return km.toStringAsFixed(1);
  }

  void _showPromoSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Promo UBantu 🎉',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                _buildPromoCard(
                  title: 'Gratis Biaya Admin!',
                  description: 'Tukar 100 poin reward untuk 1 voucher gratis biaya admin layanan.',
                  icon: Icons.card_giftcard,
                ),
                const SizedBox(height: 12),
                _buildPromoCard(
                  title: 'Bonus Poin Pertama',
                  description: 'Daftar sebagai Mitra dan selesaikan bantuan pertamamu untuk bonus 20 poin!',
                  icon: Icons.star,
                ),
                const SizedBox(height: 12),
                _buildPromoCard(
                  title: 'Ajak Teman',
                  description: 'Ajak teman mahasiswa bergabung UBantu, dapatkan masing-masing 10 poin bonus.',
                  icon: Icons.people,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromoCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF86B049).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF86B049), size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
