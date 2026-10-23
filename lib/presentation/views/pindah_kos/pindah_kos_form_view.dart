import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

class PindahKosFormView extends StatefulWidget {
  const PindahKosFormView({super.key});

  @override
  State<PindahKosFormView> createState() => _PindahKosFormViewState();
}

class _PindahKosFormViewState extends State<PindahKosFormView> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _weightController = TextEditingController();
  final _itemDescController = TextEditingController();
  final _barterDescController = TextEditingController();

  VehicleType _vehicleType = VehicleType.motor;
  BarterType _barterType = BarterType.makanan;
  DateTime? _scheduledAt;

  static const List<double> _motorWeights = [20, 50];
  static const List<double> _mobilWeights = [300, 600, 1000];

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _weightController.dispose();
    _itemDescController.dispose();
    _barterDescController.dispose();
    super.dispose();
  }

  List<double> get _availableWeights =>
      _vehicleType == VehicleType.motor ? _motorWeights : _mobilWeights;

  Future<void> _pickSchedule() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal dan waktu terlebih dahulu')),
      );
      return;
    }

    final weight = double.tryParse(_weightController.text) ?? 0;

    final provider = context.read<ServiceOrderProvider>();
    final success = await provider.createPindahKosOrder(
      locationOrigin: _originController.text.trim(),
      locationDestination: _destinationController.text.trim(),
      vehicleType: _vehicleType,
      weightKg: weight,
      itemDescription: _itemDescController.text.trim(),
      scheduledAt: _scheduledAt!,
      barterType: _barterType,
      barterDescription: _barterDescController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.pushReplacement(AppRouter.pindahKosWaiting);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal membuat pesanan'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceOrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E281C)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Formulir Pindah Kos',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E281C),
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Lokasi'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _originController,
                label: 'Lokasi Asal',
                prefixIcon: Icons.location_on_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _destinationController,
                label: 'Lokasi Tujuan',
                prefixIcon: Icons.flag_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Kendaraan'),
              const SizedBox(height: 12),
              _buildVehicleSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('Berat Barang (kg)'),
              const SizedBox(height: 12),
              _buildWeightSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('Deskripsi Barang'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _itemDescController,
                label: 'Tuliskan barang yang akan dipindah',
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Jadwal'),
              const SizedBox(height: 12),
              _buildDateTimePicker(),
              const SizedBox(height: 24),
              _buildSectionTitle('Jenis Barter'),
              const SizedBox(height: 12),
              _buildBarterTypeSelector(),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _barterDescController,
                label: 'Deskripsi barter yang ditawarkan',
                maxLines: 2,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF283626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: const Color(0xFF9E9E9E),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Meminta Bantuan',
                          style: AppTypography.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.body1.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E281C),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? prefixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8EBE4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8EBE4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF283626), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildVehicleSelector() {
    return Row(
      children: VehicleType.values.map((type) {
        final isSelected = _vehicleType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _vehicleType = type;
                _weightController.clear();
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF283626)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF283626)
                      : const Color(0xFFE8EBE4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type == VehicleType.motor
                        ? Icons.motorcycle_rounded
                        : Icons.directions_car_rounded,
                    color: isSelected ? Colors.white : const Color(0xFF5C6658),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    type == VehicleType.motor ? 'Motor' : 'Mobil',
                    style: AppTypography.body2.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? Colors.white : const Color(0xFF5C6658),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeightSelector() {
    return Wrap(
      spacing: 8,
      children: _availableWeights.map((weight) {
        final label = '${weight.toInt()} kg';
        final isSelected = _weightController.text == weight.toString();
        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) {
            setState(() {
              _weightController.text = weight.toString();
            });
          },
          selectedColor: const Color(0xFF283626),
          labelStyle: AppTypography.body2.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF1E281C),
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.white,
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF283626)
                : const Color(0xFFE8EBE4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateTimePicker() {
    return GestureDetector(
      onTap: _pickSchedule,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8EBE4)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF283626),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _scheduledAt != null
                  ? _formatDateTime(_scheduledAt!)
                  : 'Pilih tanggal & waktu',
              style: AppTypography.body2.copyWith(
                color: _scheduledAt != null
                    ? const Color(0xFF1E281C)
                    : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarterTypeSelector() {
    return Row(
      children: BarterType.values.map((type) {
        final isSelected = _barterType == type;
        final label = type == BarterType.makanan
            ? 'Makanan'
            : type == BarterType.barang
                ? 'Barang'
                : 'Lainnya';
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _barterType = type),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF283626)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF283626)
                      : const Color(0xFFE8EBE4),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTypography.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected ? Colors.white : const Color(0xFF5C6658),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
