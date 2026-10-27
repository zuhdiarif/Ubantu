import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/custom_button.dart';
import 'package:ubantu/components/custom_input_field.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/core/utils/app_validators.dart';
import 'package:ubantu/core/utils/input_formatters.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/registration_provider.dart';

class KtmVerificationView extends StatefulWidget {
  const KtmVerificationView({super.key});

  @override
  State<KtmVerificationView> createState() => _KtmVerificationViewState();
}

class _KtmVerificationViewState extends State<KtmVerificationView> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();
  File? _selectedKtmFile;
  String? _existingKtmUrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user != null) {
      if (user.nim.isNotEmpty) {
        _nimController.text = user.nim;
      }
      if (user.ktmPhotoUrl != null && user.ktmPhotoUrl!.isNotEmpty) {
        _existingKtmUrl = user.ktmPhotoUrl;
      }
    }
  }

  @override
  void dispose() {
    _nimController.dispose();
    super.dispose();
  }

  Future<void> _pickKtmPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, maxWidth: 1200, maxHeight: 800, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _selectedKtmFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showImageSourcePicker() {
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
                  'Upload Foto KTM Fisik',
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
                  subtitle: const Text('Foto fisik KTM kamu secara langsung'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickKtmPhoto(ImageSource.camera);
                  },
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
                  subtitle: const Text('Pilih foto KTM yang sudah tersimpan'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickKtmPhoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onVerify() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedKtmFile == null && _existingKtmUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih foto KTM kamu terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isAuthenticated;

    if (isLoggedIn) {
      setState(() => _isSubmitting = true);
      final file = _selectedKtmFile ?? File(_existingKtmUrl ?? '');
      final result = await authProvider.submitKtm(
        nim: _nimController.text.trim(),
        photoFile: file,
      );
      setState(() => _isSubmitting = false);

      if (mounted) {
        if (result.isSuccess) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogCtx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF86B049), size: 28),
                  SizedBox(width: 8),
                  Text('Verifikasi Dikirim'),
                ],
              ),
              content: const Text(
                'Data NIM dan berkas foto KTM kamu berhasil diunggah! Status verifikasi kamu saat ini adalah "Diproses".',
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    context.pop();
                  },
                  child: const Text('Selesai'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Gagal memproses verifikasi KTM'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      final regProvider = context.read<RegistrationProvider>();
      regProvider.setKtmData(
        nim: _nimController.text.trim(),
        photoPath: _selectedKtmFile?.path,
      );
      regProvider.updateKtmStatus(KtmVerificationStatus.pending);

      await regProvider.sendOtp();
      if (mounted) {
        context.push(AppRouter.otpVerification);
      }
    }
  }

  Widget _buildImagePreview() {
    if (_selectedKtmFile != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _selectedKtmFile!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => setState(() => _selectedKtmFile = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Ganti', style: TextStyle(fontSize: 12)),
              onPressed: _showImageSourcePicker,
            ),
          ),
        ],
      );
    }

    if (_existingKtmUrl != null && _existingKtmUrl!.isNotEmpty) {
      final isNetwork = _existingKtmUrl!.startsWith('http://') || _existingKtmUrl!.startsWith('https://');
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: isNetwork
                ? Image.network(_existingKtmUrl!, height: 200, width: double.infinity, fit: BoxFit.cover)
                : Image.file(File(_existingKtmUrl!), height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Upload Ulang', style: TextStyle(fontSize: 12)),
              onPressed: _showImageSourcePicker,
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _showImageSourcePicker,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFE2F1D8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  size: 32,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pilih / Foto Kartu Tanda Mahasiswa',
                style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mendukung format JPG, PNG kamera atau galeri',
                style: AppTypography.caption.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryDark,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Verifikasi KTM',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomInputField(
                  label: 'NIM Universitas Brawijaya',
                  placeholder: 'Contoh: 245150XXXXXXXXX',
                  controller: _nimController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [NimInputFormatter()],
                  validator: AppValidators.validateNim,
                ),
                const SizedBox(height: 20),
                Text(
                  'Foto Fisik KTM UB',
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                _buildImagePreview(),
                const SizedBox(height: 8),
                Text(
                  '*Pastikan foto jelas, nama dan NIM terlihat tidak buram',
                  style: AppTypography.body2.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F1D8).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF86B049).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.security_rounded, color: AppColors.primaryDark, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data kamu aman dan terenkripsi',
                              style: AppTypography.body1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Foto KTM hanya digunakan untuk validasi kemahasiswaan Universitas Brawijaya demi keamanan sesama mahasiswa UB.',
                              style: AppTypography.body2.copyWith(
                                color: const Color(0xFF5C6658),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                CustomButton(
                  text: _isSubmitting ? 'Mengunggah Berkas...' : 'Kirim Verifikasi KTM',
                  onPressed: _isSubmitting ? () {} : _onVerify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
