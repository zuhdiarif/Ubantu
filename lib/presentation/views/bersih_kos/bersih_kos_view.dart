import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ubantu/core/navigation/app_router.dart';

class BersihKosView extends StatefulWidget {
  const BersihKosView({super.key});

  @override
  State<BersihKosView> createState() => _BersihKosViewState();
}

class _BersihKosViewState extends State<BersihKosView> {
  int _activePromoIndex = 0;
  final PageController _promoController = PageController();

  final List<Map<String, String>> _promos = [
    {
      'title': 'Bantu bareng, ringankan beban!',
      'subtitle': 'UBantu hadir untuk membantu mahasiswa',
      'cta': 'Lihat Promo',
    },
    {
      'title': 'Kamar Bersih, Belajar Nyaman!',
      'subtitle': 'Dapatkan bantuan bersih kos antar mahasiswa UB',
      'cta': 'Lihat Promo',
    },
    {
      'title': 'Promo Barter Hemat!',
      'subtitle': 'Cukup sediakan makanan atau barang bermanfaat',
      'cta': 'Lihat Promo',
    },
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildPromoCarousel(),
                    const SizedBox(height: 12),
                    _buildCarouselIndicators(),
                    const SizedBox(height: 28),
                    _buildFiturLainnyaSection(context),
                    const SizedBox(height: 28),
                    _buildKeunggulanSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go(AppRouter.home);
              }
            },
          ),
          const Text(
            'Bersih Kos',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCarousel() {
    return SizedBox(
      height: 195,
      child: PageView.builder(
        controller: _promoController,
        onPageChanged: (index) {
          setState(() {
            _activePromoIndex = index;
          });
        },
        itemCount: _promos.length,
        itemBuilder: (context, index) {
          final promo = _promos[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: ShapeDecoration(
              color: const Color(0xFF263225),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 18,
                  top: 16,
                  bottom: 16,
                  width: 185,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promo['title']!,
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
                            promo['subtitle']!,
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
                          promo['cta']!,
                          style: const TextStyle(
                            color: Color(0xFF263225),
                            fontSize: 11,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -10,
                  top: 0,
                  bottom: 0,
                  width: 170,
                  child: Image.asset(
                    'assets/pindah_kos_flow/illust-banner-promo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.cleaning_services_rounded,
                      size: 90,
                      color: Color(0xFF86B049),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarouselIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_promos.length, (index) {
        final bool isActive = _activePromoIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 18 : 7,
          height: 7,
          decoration: ShapeDecoration(
            color: isActive ? const Color(0xFF263225) : const Color(0xFFD9D9D9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        );
      }),
    );
  }

  Widget _buildFiturLainnyaSection(BuildContext context) {
    return Column(
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
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => context.push(AppRouter.pindahKos),
                child: _buildOtherFeatureCard(
                  title: 'Pindah kos',
                  description: 'Bantu pindah barangmu',
                  imagePath: 'assets/images/ic_pindah_kos.png',
                  fallbackIcon: Icons.local_shipping_rounded,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: _buildOtherFeatureCard(
                  title: 'Antar jemput',
                  description: 'Bantu pesan antar barang',
                  imagePath: 'assets/images/ic_antar_jemput.png',
                  fallbackIcon: Icons.two_wheeler_rounded,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtherFeatureCard({
    required String title,
    required String description,
    required String imagePath,
    required IconData fallbackIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE8EBE4), width: 1),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F6EC),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                fallbackIcon,
                color: const Color(0xFF263225),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF6C7368),
                    fontSize: 11,
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
    );
  }

  Widget _buildKeunggulanSection() {
    final benefits = [
      {'icon': Icons.handshake_outlined, 'title': 'Sistem Barter', 'desc': 'Tanpa uang tunai, cukup barter makanan atau barang.'},
      {'icon': Icons.verified_user_outlined, 'title': 'Mahasiswa UB Terverifikasi', 'desc': 'Semua helper adalah mahasiswa UB aktif ber-KTM.'},
      {'icon': Icons.security_rounded, 'title': 'Keamanan Terjamin (SOS)', 'desc': 'Tombol darurat aktif saat proses pembersihan berlangsung.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kenapa Bersih Kos UBantu?',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...benefits.map((b) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2F1D8)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE2F1D8),
                child: Icon(b['icon'] as IconData, size: 20, color: const Color(0xFF263225)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b['title'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF1E281C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      b['desc'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF5C6658),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.push(AppRouter.bersihKosForm),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF263225),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Meminta Bantuan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
