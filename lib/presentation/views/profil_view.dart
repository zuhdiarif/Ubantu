import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/custom_avatar.dart';
import 'package:ubantu/components/custom_button.dart';
import 'package:ubantu/components/custom_input_field.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';

class ProfilView extends StatefulWidget {
  const ProfilView({super.key});

  @override
  State<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<ProfilView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().refreshProfile();
    });
  }

  Future<void> _pickImage(BuildContext context, AuthProvider authProvider, ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
      if (picked != null) {
        final result = await authProvider.updateAvatar(File(picked.path));
        if (context.mounted) {
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto profil berhasil diperbarui!'),
                backgroundColor: AppColors.primaryDark,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.errorMessage ?? 'Gagal mengupload foto profil'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePickerSheet(BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ubah Foto Profil',
                  style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F1D8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryDark),
                  ),
                  title: const Text('Ambil Foto Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Gunakan kamera ponsel untuk mengambil foto baru'),
                  onTap: () => _pickImage(context, authProvider, ImageSource.camera),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F1D8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.primaryDark),
                  ),
                  title: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Pilih foto yang tersimpan di galeri kamu'),
                  onTap: () => _pickImage(context, authProvider, ImageSource.gallery),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileSheet(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final nameController = TextEditingController(text: user?.fullName ?? '');
    final phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    UserGender selectedGender = user?.gender ?? UserGender.unspecified;
    bool femaleOnly = user?.isFemaleOnlyPreferred ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
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
                      'Edit Profil Pengguna',
                      style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      label: 'Nama Lengkap',
                      controller: nameController,
                      placeholder: 'Masukkan nama lengkap',
                    ),
                    const SizedBox(height: 16),
                    CustomInputField(
                      label: 'Nomor WhatsApp / HP',
                      controller: phoneController,
                      placeholder: 'Contoh: 081234567890',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Jenis Kelamin',
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Laki-laki'),
                          selected: selectedGender == UserGender.male,
                          selectedColor: const Color(0xFFE2F1D8),
                          onSelected: (val) {
                            if (val) setModalState(() => selectedGender = UserGender.male);
                          },
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Perempuan'),
                          selected: selectedGender == UserGender.female,
                          selectedColor: const Color(0xFFE2F1D8),
                          onSelected: (val) {
                            if (val) setModalState(() => selectedGender = UserGender.female);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Preferensi Khusus Mahasiswi',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Hanya terhubung dan dibantu oleh helper/mahasiswi perempuan',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      value: femaleOnly,
                      activeTrackColor: const Color(0xFF86B049),
                      onChanged: (val) {
                        setModalState(() => femaleOnly = val);
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Simpan Perubahan',
                      onPressed: () async {
                        await authProvider.updateProfile(
                          fullName: nameController.text.trim(),
                          phoneNumber: phoneController.text.trim(),
                          gender: selectedGender,
                          isFemaleOnlyPreferred: femaleOnly,
                        );
                        if (context.mounted) {
                          Navigator.of(sheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profil berhasil diperbarui!'),
                              backgroundColor: AppColors.primaryDark,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final displayName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Ahmad Farel';
    final displayEmail = user?.email.isNotEmpty == true ? user!.email : 'farel@student.ub.ac.id';

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF86B049),
          onRefresh: () => authProvider.refreshProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: () => _showImagePickerSheet(context, authProvider),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF86B049), width: 2),
                            ),
                            child: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                                ? CustomAvatar(
                                    name: displayName,
                                    imageUrl: user.avatarUrl,
                                    radius: 46,
                                  )
                                : const CircleAvatar(
                                    radius: 46,
                                    backgroundColor: Color(0xFFE2F1D8),
                                    backgroundImage: AssetImage('assets/images/img_avatar_farel.png'),
                                  ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showImagePickerSheet(context, authProvider),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryDark,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      style: AppTypography.h4.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E281C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayEmail,
                      style: AppTypography.body2.copyWith(
                        color: const Color(0xFF5C6658),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildVerificationBadge(user?.verificationStatus ?? KtmVerificationStatus.unverified),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _buildProfileOption(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profil',
                onTap: () => _showEditProfileSheet(context, authProvider),
              ),
              _buildProfileOption(
                icon: Icons.camera_alt_outlined,
                title: 'Ubah Foto Profil',
                onTap: () => _showImagePickerSheet(context, authProvider),
              ),
              _buildProfileOption(
                icon: Icons.shield_outlined,
                title: 'Verifikasi KTM UB',
                trailingWidget: _buildKtmTrailing(user?.verificationStatus ?? KtmVerificationStatus.unverified),
                onTap: () => context.push(AppRouter.ktmVerification),
              ),
              _buildProfileOption(
                icon: Icons.card_giftcard_rounded,
                title: 'Poin Reward & Voucher',
                subtitle: '${user?.rewardPoints ?? 0} Poin Tersedia',
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
    ),
  );
  }

  Widget _buildVerificationBadge(KtmVerificationStatus status) {
    final Color bgColor;
    final Color textColor;
    final IconData icon;
    final String label;

    switch (status) {
      case KtmVerificationStatus.verified:
        bgColor = const Color(0xFFE2F1D8);
        textColor = const Color(0xFF283626);
        icon = Icons.verified_rounded;
        label = 'KTM UB Terverifikasi';
        break;
      case KtmVerificationStatus.pending:
        bgColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        icon = Icons.hourglass_top_rounded;
        label = 'Verifikasi KTM Diproses';
        break;
      case KtmVerificationStatus.rejected:
        bgColor = const Color(0xFFF8D7DA);
        textColor = const Color(0xFF721C24);
        icon = Icons.cancel_outlined;
        label = 'Verifikasi KTM Ditolak';
        break;
      case KtmVerificationStatus.unverified:
        bgColor = const Color(0xFFECEFF1);
        textColor = const Color(0xFF546E7A);
        icon = Icons.shield_outlined;
        label = 'KTM Belum Terverifikasi';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKtmTrailing(KtmVerificationStatus status) {
    if (status == KtmVerificationStatus.verified) {
      return const Icon(Icons.check_circle_rounded, color: Color(0xFF86B049), size: 20);
    }
    if (status == KtmVerificationStatus.pending) {
      return const Text(
        'Diproses',
        style: TextStyle(color: Color(0xFF856404), fontSize: 12, fontWeight: FontWeight.bold),
      );
    }
    return const Icon(Icons.chevron_right_rounded, color: Colors.grey);
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    Widget? trailingWidget,
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
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(color: const Color(0xFF5C6658)),
                )
              : null,
          trailing: trailingWidget ?? const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }
}
