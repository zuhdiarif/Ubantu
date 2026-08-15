import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/custom_badge.dart';
import 'package:ubantu/components/custom_bottom_nav_bar.dart';
import 'package:ubantu/components/custom_task_card.dart';
import 'package:ubantu/components/custom_toggle_switch.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/presentation/providers/task_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _activityTab = 0;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomToggleSwitch(
                      labels: const ['Bantuan', 'Membantu'],
                      icons: const [
                        Icons.shopping_bag_outlined,
                        Icons.people_outline_rounded,
                      ],
                      selectedIndex: taskProvider.selectedModeIndex,
                      onChanged: (index) {
                        taskProvider.switchMode(index);
                      },
                    ),
                    const SizedBox(height: 20),
                    if (taskProvider.selectedModeIndex == 0) ...[
                      _buildLayananSection(),
                      const SizedBox(height: 24),
                      _buildAktivitasSayaSection(),
                    ] else ...[
                      _buildOrangButuhBantuanSection(taskProvider),
                      const SizedBox(height: 24),
                      _buildBarterSection(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() {
            _navIndex = index;
          });
        },
        onFabPressed: () {},
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hai, Anisa 👋',
                  style: AppTypography.h5.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Siap membantu hari ini?',
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLayananSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Layanan',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLayananCard(
                title: 'Bersih Kos',
                subtitle: 'Bantu beresin kos',
                svgAsset: 'assets/images/Gambar_bersih_kos.svg',
                fallbackIcon: Icons.cleaning_services_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLayananCard(
                title: 'Pindah Kos',
                subtitle: 'Bantu pindahan',
                svgAsset: 'assets/images/Gambar_pindah_kos.svg',
                fallbackIcon: Icons.inventory_2_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLayananCard(
                title: 'Antar Jemput',
                subtitle: 'Bantu antar barang atau orang',
                svgAsset: 'assets/images/Gambar_antar_jemput.svg',
                fallbackIcon: Icons.two_wheeler_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLayananCard({
    required String title,
    required String subtitle,
    required String svgAsset,
    required IconData fallbackIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            width: 60,
            child: SvgPicture.asset(
              svgAsset,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => Icon(
                fallbackIcon,
                size: 40,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.body2.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.overline.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
          'Aktivitas Saya',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        CustomToggleSwitch(
          labels: const ['Sedang Berlangsung', 'Histori'],
          selectedIndex: _activityTab,
          onChanged: (index) {
            setState(() {
              _activityTab = index;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildAktivitasItem(
          title: 'Bersih Kos',
          location: 'Jl. Merpati No. 12, Yogyakarta',
          dateTime: '2 Jun 2025 • 10:00',
          iconColor: Colors.green,
          icon: Icons.cleaning_services_rounded,
        ),
        _buildAktivitasItem(
          title: 'Pindah Kos',
          location: 'Jl. Kaliurang Km 5, Yogyakarta',
          dateTime: '1 Jun 2025 • 14:30',
          iconColor: Colors.amber,
          icon: Icons.inventory_2_rounded,
        ),
        _buildAktivitasItem(
          title: 'Antar Jemput',
          location: 'Jl. Seturan No. 45, Yogyakarta',
          dateTime: '31 Mei 2025 • 09:00',
          iconColor: Colors.blue,
          icon: Icons.two_wheeler_rounded,
        ),
      ],
    );
  }

  Widget _buildAktivitasItem({
    required String title,
    required String location,
    required String dateTime,
    required Color iconColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withValues(alpha: 0.15),
            child: Icon(icon, color: iconColor, size: 20),
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
                Text(
                  location,
                  style: AppTypography.body2.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  dateTime,
                  style: AppTypography.body2.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const CustomBadge(text: 'Berlangsung', type: BadgeType.green),
        ],
      ),
    );
  }

  Widget _buildOrangButuhBantuanSection(TaskProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Orang yang Butuh Bantuan',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        ...provider.tasks.map((task) {
          BadgeType bType = BadgeType.green;
          if (task.category == ServiceCategory.pindahKos) {
            bType = BadgeType.orange;
          } else if (task.category == ServiceCategory.antarJemput) {
            bType = BadgeType.blue;
          }

          return CustomTaskCard(
            name: task.requesterName,
            rating: task.rating,
            ratingCount: task.ratingCount,
            badgeText: task.title,
            badgeType: bType,
            location: task.location,
            date: task.date,
            time: task.time,
            onDetailPressed: () => context.push(AppRouter.helpDetail),
          );
        }),
      ],
    );
  }

  Widget _buildBarterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Barter yang Tersedia',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.fastfood_rounded,
                      size: 32,
                      color: AppColors.accentOrange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Makanan',
                            style: AppTypography.body1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          Text(
                            'Tukar dengan makanan',
                            style: AppTypography.body2.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard_rounded,
                      size: 32,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Barang',
                            style: AppTypography.body1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          Text(
                            'Tukar dengan barang',
                            style: AppTypography.body2.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
