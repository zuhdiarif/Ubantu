import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';

class ProfilView extends StatelessWidget {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil Pengguna',
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E281C),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 46,
                      backgroundColor: Color(0xFFE2F1D8),
                      backgroundImage: AssetImage('assets/images/img_avatar_farel.png'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName.isNotEmpty == true ? user!.fullName : 'Ahmad Farel',
                      style: AppTypography.h4.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E281C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email.isNotEmpty == true ? user!.email : 'farel@student.ub.ac.id',
                      style: AppTypography.body2.copyWith(
                        color: const Color(0xFF5C6658),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F1D8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF283626)),
                          const SizedBox(width: 6),
                          Text(
                            'KTM UB Terverifikasi',
                            style: AppTypography.caption.copyWith(
                              color: const Color(0xFF283626),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _buildProfileOption(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profil',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.engineering_rounded,
                title: 'Mode Mitra (Bantu Mahasiswa Lain)',
                onTap: () => context.push(AppRouter.mitraDashboard),
              ),
              _buildProfileOption(
                icon: Icons.shield_outlined,
                title: 'Verifikasi KTM UB',
                onTap: () => context.push(AppRouter.ktmVerification),
              ),
              _buildProfileOption(
                icon: Icons.card_giftcard_rounded,
                title: 'Poin Reward & Voucher',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.sos_rounded,
                title: 'Pengaturan Tombol SOS Darurat',
                onTap: () => context.push(AppRouter.sosForm),
              ),
              _buildProfileOption(
                icon: Icons.logout_rounded,
                title: 'Keluar Akun',
                textColor: Colors.red,
                onTap: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    context.go(AppRouter.login);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF1E281C),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE8EBE4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(icon, color: textColor),
          title: Text(
            title,
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}
