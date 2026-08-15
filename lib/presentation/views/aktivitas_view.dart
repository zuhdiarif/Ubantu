import 'package:flutter/material.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';

class AktivitasView extends StatefulWidget {
  const AktivitasView({super.key});

  @override
  State<AktivitasView> createState() => _AktivitasViewState();
}

class _AktivitasViewState extends State<AktivitasView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Aktivitas Saya',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E281C),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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
                          color: _selectedTab == 0 ? const Color(0xFF283626) : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Sedang Berlangsung',
                          style: AppTypography.body2.copyWith(
                            fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.w500,
                            color: _selectedTab == 0 ? Colors.white : const Color(0xFF283626),
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
                          color: _selectedTab == 1 ? const Color(0xFF283626) : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Histori Selesai',
                          style: AppTypography.body2.copyWith(
                            fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.w500,
                            color: _selectedTab == 1 ? Colors.white : const Color(0xFF283626),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedTab == 0) ...[
              _buildAktivitasItem(
                title: 'Bersih kos',
                location: 'Jl.Veteran, Malang',
                dateTime: '20 Juli 2026 - 09:00',
                imageAsset: 'assets/images/ic_bersih_kos.png',
                statusText: 'Berlangsung',
              ),
            ] else ...[
              _buildAktivitasItem(
                title: 'Pindah kos',
                location: 'Jl. MT Haryono Gg 8, Malang',
                dateTime: '15 Juli 2026 - 13:30',
                imageAsset: 'assets/images/ic_pindah_kos.png',
                statusText: 'Selesai',
              ),
              _buildAktivitasItem(
                title: 'Antar jemput',
                location: 'Stasiun Malang Kota Baru',
                dateTime: '10 Juli 2026 - 20:15',
                imageAsset: 'assets/images/ic_antar_jemput.png',
                statusText: 'Selesai',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAktivitasItem({
    required String title,
    required String location,
    required String dateTime,
    required String imageAsset,
    required String statusText,
  }) {
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
              color: statusText == 'Berlangsung' ? const Color(0xFFE2F1D8) : Colors.grey.shade200,
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
}
