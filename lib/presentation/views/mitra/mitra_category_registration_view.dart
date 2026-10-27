import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';

class MitraCategoryRegistrationView extends StatefulWidget {
  const MitraCategoryRegistrationView({super.key});

  @override
  State<MitraCategoryRegistrationView> createState() =>
      _MitraCategoryRegistrationViewState();
}

class _MitraCategoryRegistrationViewState
    extends State<MitraCategoryRegistrationView> {
  late Set<ServiceCategory> _selectedCategories;
  final TextEditingController _vehicleInfoController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  VehicleType _selectedVehicleType = VehicleType.motor;

  @override
  void initState() {
    super.initState();
    final profile = context.read<MitraProvider>().profile;
    _selectedCategories = Set.from(
      profile?.selectedCategories ??
          [
            ServiceCategory.pindahKos,
            ServiceCategory.bersihKos,
            ServiceCategory.antarJemput,
          ],
    );
    _vehicleInfoController.text =
        profile?.vehicleInfo ?? 'Honda Vario 160 Hitam';
    _plateController.text = profile?.vehiclePlate ?? 'N 4821 ABC';
  }

  @override
  void dispose() {
    _vehicleInfoController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MitraProvider>();
    final profile = provider.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Kategori & Kendaraan Mitra',
          style: AppTypography.h5.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKtmVerificationCard(profile?.isKtmVerified ?? true),
            const SizedBox(height: 20),
            Text(
              'Layanan yang Anda Kuasai',
              style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih minimal 1 jenis layanan yang ingin Anda tawarkan kepada sesama mahasiswa UB.',
              style: AppTypography.caption.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            _buildServiceOptionCard(
              category: ServiceCategory.pindahKos,
              title: 'Pindah Kos Mahasiswa',
              desc:
                  'Bantu angkut barang kos, bawa koper, kardus buku, dan perabotan kecil.',
              icon: Icons.inventory_2_outlined,
            ),
            const SizedBox(height: 10),
            _buildServiceOptionCard(
              category: ServiceCategory.bersihKos,
              title: 'Bersih Kamar Kos',
              desc:
                  'Bantu sapu, pel lantai, bersihkan kamar mandi, dan rapikan kamar.',
              icon: Icons.cleaning_services_outlined,
            ),
            const SizedBox(height: 10),
            _buildServiceOptionCard(
              category: ServiceCategory.antarJemput,
              title: 'Antar Jemput / Tebengan',
              desc:
                  'Bantu tebengan motor/mobil ke kampus UB, stasiun, atau terminal di Malang.',
              icon: Icons.two_wheeler_outlined,
            ),
            const SizedBox(height: 24),
            Text(
              'Informasi Kendaraan',
              style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildVehicleSection(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (_selectedCategories.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pilih minimal satu kategori layanan!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  await provider.updateCategories(_selectedCategories.toList());
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pengaturan layanan mitra berhasil disimpan!',
                        ),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                    context.pop();
                  }
                },
                child: Text(
                  'Simpan Pengaturan',
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKtmVerificationCard(bool isVerified) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isVerified
              ? AppColors.primaryGreen.withValues(alpha: 0.4)
              : Colors.amber,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isVerified
                  ? AppColors.primaryGreen.withValues(alpha: 0.15)
                  : Colors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVerified ? Icons.verified_user_rounded : Icons.pending_actions,
              color: isVerified
                  ? AppColors.primaryGreen
                  : Colors.amber.shade800,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVerified
                      ? 'KTM Mahasiswa UB Terverifikasi'
                      : 'Verifikasi KTM Tertunda',
                  style: AppTypography.body2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isVerified
                      ? 'Identitas aktif Universitas Brawijaya tervalidasi. Anda dapat menerima semua kategori order.'
                      : 'Unggah foto KTM untuk mengaktifkan order.',
                  style: AppTypography.caption.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOptionCard({
    required ServiceCategory category,
    required String title,
    required String desc,
    required IconData icon,
  }) {
    final isSelected = _selectedCategories.contains(category);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCategories.remove(category);
          } else {
            _selectedCategories.add(category);
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primarySage.withValues(alpha: 0.3)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryGreen
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: AppTypography.caption.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: isSelected,
              activeColor: AppColors.primaryGreen,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipe Kendaraan',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.two_wheeler, size: 18),
                      SizedBox(width: 6),
                      Text('Sepeda Motor'),
                    ],
                  ),
                  selected: _selectedVehicleType == VehicleType.motor,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: TextStyle(
                    color: _selectedVehicleType == VehicleType.motor
                        ? Colors.white
                        : AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedVehicleType = VehicleType.motor);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car, size: 18),
                      SizedBox(width: 6),
                      Text('Mobil'),
                    ],
                  ),
                  selected: _selectedVehicleType == VehicleType.mobil,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: TextStyle(
                    color: _selectedVehicleType == VehicleType.mobil
                        ? Colors.white
                        : AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedVehicleType = VehicleType.mobil);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Merek & Tipe Kendaraan',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _vehicleInfoController,
            decoration: InputDecoration(
              hintText: 'Contoh: Honda Vario 160 Hitam',
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Nomor Plat Polisi',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _plateController,
            decoration: InputDecoration(
              hintText: 'Contoh: N 4821 ABC',
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
