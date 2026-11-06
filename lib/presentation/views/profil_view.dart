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
import 'package:ubantu/presentation/providers/barter_provider.dart';
import 'package:ubantu/presentation/providers/chat_provider.dart';
import 'package:ubantu/presentation/providers/loyalty_provider.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';
import 'package:ubantu/presentation/providers/notification_provider.dart';
import 'package:ubantu/presentation/providers/profile_provider.dart';
import 'package:ubantu/presentation/providers/rating_provider.dart';
import 'package:ubantu/presentation/providers/schedule_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';
import 'package:ubantu/presentation/providers/sos_provider.dart';
import 'package:ubantu/presentation/providers/task_provider.dart';

class ProfilView extends StatefulWidget {
  const ProfilView({super.key});

  @override
  State<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<ProfilView> {
  void _resetUserSessionProviders(BuildContext context) {
    try {
      context.read<MitraProvider>().resetSession();
    } catch (_) {}
    try {
      context.read<ServiceOrderProvider>().resetSession();
    } catch (_) {}
    try {
      context.read<ProfileProvider>().resetSession();
    } catch (_) {}
    try {
      context.read<NotificationProvider>().resetSession();
    } catch (_) {}
    try {
      context.read<ScheduleProvider>().resetSession();
    } catch (_) {}
    try {
      context.read<BarterProvider>().resetSession();
    } catch (_) {}
    try {
      context.read<RatingProvider>().resetSession();
    } catch (_) {}
    try {
      context.read<TaskProvider>().resetSession();
    } catch (_) {}
    try {
      context.read<SosProvider>().resetSession();
    } catch (_) {}
    try {
      context.read<ChatProvider>().resetSession();
    } catch (_) {}
    try {
      context.read<LoyaltyProvider>().resetSession();
    } catch (_) {}
  }

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
        final file = File(picked.path);
        if (await file.length() > 5 * 1024 * 1024) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ukuran file maksimal 5 MB. Silakan pilih file yang lebih kecil.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        final result = await authProvider.updateAvatar(file);
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
    final facultyController = TextEditingController(text: user?.faculty ?? '');
    final bioController = TextEditingController(text: user?.bio ?? '');
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
                    CustomInputField(
                      label: 'Fakultas / Jurusan',
                      controller: facultyController,
                      placeholder: 'Contoh: FILKOM / Teknik Informatika',
                    ),
                    const SizedBox(height: 16),
                    CustomInputField(
                      label: 'Bio Singkat',
                      controller: bioController,
                      placeholder: 'Ceritakan sedikit tentang dirimu...',
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
                          faculty: facultyController.text.trim(),
                          bio: bioController.text.trim(),
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

  void _showLoyaltySheet(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final points = user?.rewardPoints ?? 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Poin Reward & Voucher',
                    style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F1D8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded, color: Color(0xFF86B049), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$points Poin',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2F3E2E),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Kumpulkan poin dari setiap bantuan yang berhasil diselesaikan dan tukarkan dengan voucher mitra kampus.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: Color(0xFF70776D),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8D8)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF86B049),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.confirmation_num_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voucher Diskon Kantin UB',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF263225),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Potongan Rp 5.000 (Min. 50 Poin)',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: Color(0xFF70776D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF263225),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Voucher diskon kantin berhasil diklaim!'),
                            backgroundColor: Color(0xFF263225),
                          ),
                        );
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('Klaim', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAccountSettingsSheet(BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                'Pengaturan Akun',
                style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_reset_rounded, color: AppColors.primaryDark),
                title: const Text('Ubah Password', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Reset password via kode OTP ke email'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push(AppRouter.forgotPassword);
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                title: const Text('Hapus Akun', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                subtitle: const Text('Hapus akun dan semua data secara permanen'),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.red),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showDeleteAccountDialog(context, authProvider);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Hapus Akun', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'Apakah kamu yakin ingin menghapus akun? Semua data profil dan riwayat bantuan akan dihapus secara permanen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                _resetUserSessionProviders(context);
                await authProvider.logout();
                if (context.mounted) {
                  context.go(AppRouter.login);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Akun berhasil dihapus'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showFaqSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ListView(
                controller: scrollController,
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
                    'Bantuan & Pusat Informasi (FAQ)',
                    style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const ExpansionTile(
                    title: Text(
                      'Bagaimana cara verifikasi KTM UB?',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 12, left: 16, right: 16),
                        child: Text(
                          'Unggah foto KTM UB aktif dan masukkan NIM Anda pada menu Verifikasi KTM UB. Verifikasi akan diproses maksimal 1x24 jam oleh sistem.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF5C6658)),
                        ),
                      ),
                    ],
                  ),
                  const ExpansionTile(
                    title: Text(
                      'Bagaimana cara menjadi Mitra UBantu?',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 12, left: 16, right: 16),
                        child: Text(
                          'Setelah KTM Anda terverifikasi, buka menu Dashboard dan aktifkan status aktif Anda untuk menerima pesanan bantuan dari mahasiswa UB lainnya.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF5C6658)),
                        ),
                      ),
                    ],
                  ),
                  const ExpansionTile(
                    title: Text(
                      'Bagaimana sistem reward poin bekerja?',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 12, left: 16, right: 16),
                        child: Text(
                          'Setiap kali Anda berhasil menyelesaikan bantuan, poin reward akan ditambahkan ke akun Anda dan dapat ditukarkan di masa mendatang.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF5C6658)),
                        ),
                      ),
                    ],
                  ),
                  const ExpansionTile(
                    title: Text(
                      'Kapan fitur Tombol SOS digunakan?',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 12, left: 16, right: 16),
                        child: Text(
                          'Tombol SOS digunakan saat keadaan darurat atau bahaya di kampus untuk menyiarkan sinyal darurat ke mahasiswa terdekat dan tim keamanan.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF5C6658)),
                        ),
                      ),
                    ],
                  ),
                ],
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
    final displayName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Mahasiswa UB';
    final displayEmail = user?.email.isNotEmpty == true ? user!.email : 'mahasiswa@student.ub.ac.id';

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
                            child: CustomAvatar(
                              name: displayName,
                              imageUrl: user?.avatarUrl,
                              radius: 46,
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
                    if (user?.faculty != null && user!.faculty!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.faculty!,
                        style: AppTypography.body2.copyWith(
                          color: const Color(0xFF86B049),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          user.bio!,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF5C6658),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildVerificationBadge(user?.verificationStatus ?? KtmVerificationStatus.unverified),
                    if (user?.emailOtpSkipped == true) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFEEBA)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Color(0xFF856404), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Email belum diverifikasi',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFF856404),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                icon: Icons.dashboard,
                title: 'Dashboard',
                onTap: () => context.push(AppRouter.mitraDashboard),
              ),
              _buildProfileOption(
                icon: Icons.history,
                title: 'Riwayat Bantuan',
                onTap: () => context.push(AppRouter.aktivitas),
              ),
              _buildProfileOption(
                icon: Icons.card_giftcard_rounded,
                title: 'Poin Reward & Voucher',
                subtitle: '${user?.rewardPoints ?? 0} Poin Tersedia',
                onTap: () => _showLoyaltySheet(context, authProvider),
              ),
              _buildProfileOption(
                icon: Icons.settings,
                title: 'Pengaturan Akun',
                onTap: () => _showAccountSettingsSheet(context, authProvider),
              ),
              _buildProfileOption(
                icon: Icons.help_outline,
                title: 'Bantuan & Pusat Informasi (FAQ)',
                onTap: () => _showFaqSheet(context),
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
                  _resetUserSessionProviders(context);
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
