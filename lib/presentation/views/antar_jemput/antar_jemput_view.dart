import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ubantu/core/navigation/app_router.dart';

class AntarJemputView extends StatefulWidget {
  const AntarJemputView({super.key});

  @override
  State<AntarJemputView> createState() => _AntarJemputViewState();
}

class _AntarJemputViewState extends State<AntarJemputView> {
  final PageController _pageController = PageController();
  int _currentBannerIndex = 0;

  final List<Map<String, String>> _bannerItems = [
    {
      'title': 'Mobilitas Cepat, Ongkos Hemat!',
      'subtitle': 'UBantu hadir bantu antar barang & tebengan mahasiswa',
      'cta': 'Lihat Promo',
    },
    {
      'title': 'Kirim Tugas & Barang Kilat!',
      'subtitle': 'Antar paket praktis seputar kampus Universitas Brawijaya',
      'cta': 'Lihat Promo',
    },
    {
      'title': 'Aman & Tepercaya!',
      'subtitle': 'Kurir sesama mahasiswa UB dengan KTM terverifikasi',
      'cta': 'Lihat Promo',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRouter.home);
            }
          },
        ),
        title: const Text(
          'Antar Jemput',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildPromoCarousel(),
                const SizedBox(height: 14),
                _buildPageIndicator(),
                const SizedBox(height: 24),
                _buildOtherFeatures(),
                const SizedBox(height: 24),
                _buildServicePerks(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCarousel() {
    return SizedBox(
      height: 185,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentBannerIndex = index;
          });
        },
        itemCount: _bannerItems.length,
        itemBuilder: (context, index) {
          final item = _bannerItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: ShapeDecoration(
                color: const Color(0xFF263225),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -15,
                    child: Opacity(
                      opacity: 0.18,
                      child: const Icon(
                        Icons.two_wheeler_rounded,
                        size: 170,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 16,
                    bottom: 16,
                    width: 190,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['subtitle']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFD4DEC9),
                                fontSize: 11,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w400,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF8FAF4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            item['cta']!,
                            style: const TextStyle(
                              color: Color(0xFF263225),
                              fontSize: 12,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _bannerItems.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentBannerIndex == index ? 18 : 7,
          height: 7,
          decoration: ShapeDecoration(
            color: _currentBannerIndex == index
                ? const Color(0xFF263225)
                : const Color(0xFFD9D9D9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherFeatures() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fitur lainnya',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  title: 'Pindah kos',
                  subtitle: 'Bantu pindah barangmu',
                  icon: Icons.local_shipping_rounded,
                  iconColor: const Color(0xFF86B049),
                  onTap: () => context.push(AppRouter.pindahKos),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  title: 'Bersih kos',
                  subtitle: 'Bantu bersihkan kos kamu',
                  icon: Icons.cleaning_services_rounded,
                  iconColor: const Color(0xFF23A23F),
                  onTap: () => context.push(AppRouter.bersihKos),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE8EBE4), width: 1),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: ShapeDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF70776D),
                      fontSize: 10,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicePerks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keunggulan Antar Jemput UBantu',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildPerkTile(
            icon: Icons.two_wheeler_rounded,
            title: 'Pilihan Motor & Mobil Fleksibel',
            description: 'Cocok untuk kirim paket, dokumen kuliah, maupun tebengan barang bawaan.',
          ),
          const SizedBox(height: 10),
          _buildPerkTile(
            icon: Icons.near_me_rounded,
            title: 'Jangkauan Wilayah Kampus UB (Radius 5 km)',
            description: 'Penjemputan dan pengantaran cepat di area lingkar kampus Brawijaya Malang.',
          ),
          const SizedBox(height: 10),
          _buildPerkTile(
            icon: Icons.handshake_rounded,
            title: 'Sistem Barter Ramah Kantong Mahasiswa',
            description: 'Bisa dibarter dengan makanan, barang bermanfaat, atau jasa antar-mahasiswa.',
          ),
        ],
      ),
    );
  }

  Widget _buildPerkTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EBE4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF263225),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF6C7368),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            context.push(AppRouter.antarJemputForm);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF263225),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Meminta Bantuan',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
