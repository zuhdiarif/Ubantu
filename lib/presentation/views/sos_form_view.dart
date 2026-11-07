import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/custom_button.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/sos_report_model.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/sos_provider.dart';

enum SosEmergencyType { medis, keamanan, kecelakaan, lainnya }

extension SosProviderFormExtension on SosProvider {
  Future<AppResult<SosReportModel>> triggerSos({
    required SosEmergencyType type,
    required String details,
    required double latitude,
    required double longitude,
    required bool shareLiveLocation,
    required String userId,
  }) async {
    try {
      await submitReport(details);
      final report = activeReport ??
          SosReportModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            issueType: details,
            status: SosStatus.received,
            createdAt: DateTime.now(),
          );
      return AppResult.success(report);
    } catch (e) {
      return AppResult.failure('Gagal mengirim sinyal darurat: $e');
    }
  }
}

class SosFormView extends StatefulWidget {
  const SosFormView({super.key});

  @override
  State<SosFormView> createState() => _SosFormViewState();
}

class _SosFormViewState extends State<SosFormView> {
  String _selectedCategory = 'Medis / Kecelakaan';
  final String _selectedLocation = 'Area Kampus UB Malang';
  final TextEditingController _detailController = TextEditingController();
  bool _shareToEmergencyContact = true;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Medis / Kecelakaan',
      'subtitle': 'Luka fisik, pingsan, atau insiden kecelakaan lalu lintas.',
      'icon': Icons.medical_services_outlined,
    },
    {
      'title': 'Ancaman Keamanan',
      'subtitle': 'Merasa terancam, diikuti orang mencurigakan, atau pelecehan.',
      'icon': Icons.shield_outlined,
    },
    {
      'title': 'Kendaraan Mogok Malam',
      'subtitle': 'Ban bocor, mesin mati, atau kehabisan bensin di malam hari.',
      'icon': Icons.two_wheeler_outlined,
    },
    {
      'title': 'Kondisi Darurat Lainnya',
      'subtitle': 'Situasi genting lain yang memerlukan pendampingan segera.',
      'icon': Icons.warning_amber_rounded,
    },
  ];

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  SosEmergencyType _mapCategoryToEmergencyType(String category) {
    if (category == 'Medis / Kecelakaan') return SosEmergencyType.medis;
    if (category == 'Ancaman Keamanan') return SosEmergencyType.keamanan;
    if (category == 'Kendaraan Mogok Malam') return SosEmergencyType.kecelakaan;
    return SosEmergencyType.lainnya;
  }

  Future<void> _triggerSos() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final emergencyType = _mapCategoryToEmergencyType(_selectedCategory);
    final details = '$_selectedLocation: ${_detailController.text.trim()}';
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';

    final res = await context.read<SosProvider>().triggerSos(
          type: emergencyType,
          details: details,
          latitude: -7.9525,
          longitude: 112.6139,
          shareLiveLocation: _shareToEmergencyContact,
          userId: userId,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.errorMessage ?? 'Gagal mengirim sinyal darurat'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.pushReplacement(AppRouter.sosActive);
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
          'Konfirmasi SOS',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Butuh bantuan?',
                  style: AppTypography.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Pilih jenis bantuan yang sesuai dengan situasi yang kamu alami.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body1.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              for (int i = 0; i < _categories.length; i++) ...[
                _buildRadioOption(
                  title: _categories[i]['title'] as String,
                  subtitle: _categories[i]['subtitle'] as String,
                  icon: _categories[i]['icon'] as IconData,
                  isSelected: _selectedCategory == _categories[i]['title'],
                  onTap: () {
                    setState(() {
                      _selectedCategory = _categories[i]['title'] as String;
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan Tambahan (Opsional)',
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _detailController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan detail lokasi atau kondisi...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF8FAF4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryGreen),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _shareToEmergencyContact,
                          activeColor: AppColors.primaryGreen,
                          onChanged: (val) {
                            setState(() {
                              _shareToEmergencyContact = val ?? true;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Bagikan live lokasi ke kontak darurat terdaftar',
                            style: AppTypography.body2.copyWith(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tim kami akan segera merespon laporan kamu dan menghubungi dalam waktu tercepat.',
                        style: AppTypography.body2.copyWith(
                          color: const Color(0xFFC62828),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isSubmitting ? 'Mengirim Sinyal...' : 'Kirim Bantuan',
                type: CustomButtonType.danger,
                icon: Icons.send_rounded,
                onPressed: _isSubmitting ? null : _triggerSos,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primaryGreen : Colors.grey.shade600,
                size: 24,
              ),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.body2.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
