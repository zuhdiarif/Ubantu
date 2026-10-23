import 'package:flutter/material.dart';
import 'package:ubantu/core/navigation/app_router.dart';

class DebugFloatingMenu extends StatefulWidget {
  const DebugFloatingMenu({super.key});

  @override
  State<DebugFloatingMenu> createState() => _DebugFloatingMenuState();
}

class _DebugFloatingMenuState extends State<DebugFloatingMenu> {
  double? _x;
  double? _y;
  bool _isOpen = false;

  final List<Map<String, dynamic>> _routeGroups = [
    {
      'title': 'Alur Pindah Kos (5 Layar)',
      'routes': [
        {'name': '1. Promo & Beranda', 'route': AppRouter.pindahKos, 'icon': Icons.local_shipping_rounded},
        {'name': '2. Formulir Permintaan', 'route': AppRouter.pindahKosForm, 'icon': Icons.assignment_rounded},
        {'name': '3. Menunggu Bantuan', 'route': AppRouter.pindahKosWaiting, 'icon': Icons.hourglass_top_rounded},
        {'name': '4. Bantuan Berlangsung', 'route': AppRouter.pindahKosInProgress, 'icon': Icons.navigation_rounded},
        {'name': '5. Bantuan Selesai & Ulasan', 'route': AppRouter.pindahKosSelesai, 'icon': Icons.star_rounded},
      ],
    },
    {
      'title': 'Alur Bersih Kos (5 Layar)',
      'routes': [
        {'name': '1. Promo Bersih Kos', 'route': AppRouter.bersihKos, 'icon': Icons.cleaning_services_rounded},
        {'name': '2. Formulir Bersih Kos', 'route': AppRouter.bersihKosForm, 'icon': Icons.assignment_rounded},
        {'name': '3. Menunggu Helper Bersih', 'route': AppRouter.bersihKosWaiting, 'icon': Icons.hourglass_top_rounded},
        {'name': '4. Bersih Berlangsung', 'route': AppRouter.bersihKosInProgress, 'icon': Icons.navigation_rounded},
        {'name': '5. Selesai & Ulasan Bersih', 'route': AppRouter.bersihKosSelesai, 'icon': Icons.star_rounded},
      ],
    },
    {
      'title': 'Fitur Chat & Percakapan',
      'routes': [
        {'name': '1. Inbox Percakapan', 'route': AppRouter.chatInbox, 'icon': Icons.inbox_rounded},
        {'name': '2. Ruang Chat Interaktif', 'route': AppRouter.chatRoom, 'icon': Icons.chat_rounded},
      ],
    },
    {
      'title': 'Aplikasi & Fitur Utama',
      'routes': [
        {'name': 'Beranda Utama', 'route': AppRouter.home, 'icon': Icons.home_rounded},
        {'name': 'Detail Bantuan', 'route': AppRouter.helpDetail, 'icon': Icons.info_outline_rounded},
        {'name': 'Form SOS Darurat', 'route': AppRouter.sosForm, 'icon': Icons.sos_rounded},
        {'name': 'Tracking SOS Aktif', 'route': AppRouter.sosActive, 'icon': Icons.location_on_rounded},
        {'name': 'Dialog SOS Selesai', 'route': AppRouter.sosFinish, 'icon': Icons.check_circle_rounded},
      ],
    },
    {
      'title': 'Autentikasi & Akun',
      'routes': [
        {'name': 'Onboarding', 'route': AppRouter.onboarding, 'icon': Icons.explore_rounded},
        {'name': 'Login', 'route': AppRouter.login, 'icon': Icons.login_rounded},
        {'name': 'Register', 'route': AppRouter.register, 'icon': Icons.app_registration_rounded},
        {'name': 'Verifikasi KTM', 'route': AppRouter.ktmVerification, 'icon': Icons.badge_rounded},
        {'name': 'Verifikasi OTP', 'route': AppRouter.otpVerification, 'icon': Icons.password_rounded},
      ],
    },
  ];

  void _navigateTo(String route) {
    setState(() => _isOpen = false);
    AppRouter.router.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenW = size.width > 0 ? size.width : 390.0;
    final screenH = size.height > 0 ? size.height : 800.0;

    _x ??= (screenW - 72.0).clamp(16.0, screenW - 72.0);
    _y ??= (screenH - 180.0).clamp(60.0, screenH - 100.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _isOpen = false),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          if (_isOpen)
            Center(
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                elevation: 12,
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: size.width * 0.88,
                  height: size.height * 0.72,
                  child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF263225),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.alt_route_rounded, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Navigasi Debug',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isOpen = false),
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.close_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _routeGroups.length,
                        itemBuilder: (context, gIdx) {
                          final group = _routeGroups[gIdx];
                          final routes = group['routes'] as List<Map<String, dynamic>>;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                                child: Text(
                                  group['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF86B049),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              ...routes.map((r) {
                                return ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: const Color(0xFFE2F1D8),
                                    child: Icon(
                                      r['icon'] as IconData,
                                      size: 15,
                                      color: const Color(0xFF263225),
                                    ),
                                  ),
                                  title: Text(
                                    r['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E281C),
                                    ),
                                  ),
                                  subtitle: Text(
                                    r['route'] as String,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: Color(0xFF5C6658),
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 13,
                                    color: Color(0xFF858585),
                                  ),
                                  onTap: () => _navigateTo(r['route'] as String),
                                );
                              }),
                              const Divider(height: 16, thickness: 0.5),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: _x,
            top: _y,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                setState(() {
                  _x = (_x! + details.delta.dx).clamp(8.0, screenW - 64.0);
                  _y = (_y! + details.delta.dy).clamp(30.0, screenH - 64.0);
                });
              },
              onTap: () => setState(() => _isOpen = !_isOpen),
              child: Material(
                color: Colors.transparent,
                elevation: 10,
                shape: const CircleBorder(),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF263225),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF86B049), width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          _isOpen ? Icons.close_rounded : Icons.alt_route_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4A261),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
  }
}
