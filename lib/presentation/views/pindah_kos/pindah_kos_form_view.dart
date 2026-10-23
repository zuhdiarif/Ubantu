import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

enum _VehicleOption {
  motor,
  mobilBoxKecil,
  mobilBoxSedang,
  mobilBoxBesar,
}

class PindahKosFormView extends StatefulWidget {
  const PindahKosFormView({super.key});

  @override
  State<PindahKosFormView> createState() => _PindahKosFormViewState();
}

class _PindahKosFormViewState extends State<PindahKosFormView> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _itemDescController = TextEditingController();
  final _barterDescController = TextEditingController();

  _VehicleOption _selectedVehicle = _VehicleOption.motor;
  double _motorSelectedWeight = 20.0;
  BarterType _selectedBarterType = BarterType.makanan;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _itemDescController.dispose();
    _barterDescController.dispose();
    super.dispose();
  }

  void _swapLocations() {
    final temp = _originController.text;
    _originController.text = _destinationController.text;
    _destinationController.text = temp;
    setState(() {});
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF263225),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF263225),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal dan waktu terlebih dahulu')),
      );
      return;
    }

    final scheduledAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    VehicleType vehicleType;
    double weightKg;

    switch (_selectedVehicle) {
      case _VehicleOption.motor:
        vehicleType = VehicleType.motor;
        weightKg = _motorSelectedWeight;
        break;
      case _VehicleOption.mobilBoxKecil:
        vehicleType = VehicleType.mobil;
        weightKg = 300.0;
        break;
      case _VehicleOption.mobilBoxSedang:
        vehicleType = VehicleType.mobil;
        weightKg = 600.0;
        break;
      case _VehicleOption.mobilBoxBesar:
        vehicleType = VehicleType.mobil;
        weightKg = 1000.0;
        break;
    }

    final provider = context.read<ServiceOrderProvider>();
    final success = await provider.createPindahKosOrder(
      locationOrigin: _originController.text.trim(),
      locationDestination: _destinationController.text.trim(),
      vehicleType: vehicleType,
      weightKg: weightKg,
      itemDescription: _itemDescController.text.trim().isEmpty
          ? 'Barang pindah kos'
          : _itemDescController.text.trim(),
      scheduledAt: scheduledAt,
      barterType: _selectedBarterType,
      barterDescription: _barterDescController.text.trim().isEmpty
          ? 'Sesuai kesepakatan'
          : _barterDescController.text.trim(),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Pindah Kos',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/pindah_kos_flow/ph_dots-three-circle-vertical-fill.svg',
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Permintaan',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLocationSection(),
                      const SizedBox(height: 24),
                      _buildVehicleSection(),
                      const SizedBox(height: 24),
                      _buildItemDescriptionSection(),
                      const SizedBox(height: 24),
                      _buildDateTimeSection(),
                      const SizedBox(height: 24),
                      _buildBarterSection(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF263225),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
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
                      : const Text(
                          'Meminta Bantuan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 0.50,
                        color: Color(0xFF263225),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/pindah_kos_flow/carbon_location.svg',
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.location_on, color: Color(0xFF263225)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Dari ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '(Kos Semula)',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: _originController,
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Plus Jakarta Sans',
                                color: Colors.black,
                              ),
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'Lokasi asal wajib diisi'
                                  : null,
                              decoration: const InputDecoration(
                                hintText: 'Jl. Kaliurang Km 5, Malang',
                                hintStyle: TextStyle(
                                  color: Color(0xFFAEABAA),
                                  fontSize: 12,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(top: 4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 0.50,
                        color: Color(0xFF263225),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/pindah_kos_flow/pin-lokasi.svg',
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.flag, color: Color(0xFF263225)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Ke ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '(Kos Tujuan)',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: _destinationController,
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Plus Jakarta Sans',
                                color: Colors.black,
                              ),
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'Lokasi tujuan wajib diisi'
                                  : null,
                              decoration: const InputDecoration(
                                hintText: 'Jl. Gajayana No.12, Malang',
                                hintStyle: TextStyle(
                                  color: Color(0xFFAEABAA),
                                  fontSize: 12,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(top: 4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 18,
              top: 50,
              child: GestureDetector(
                onTap: _swapLocations,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF263225),
                      width: 0.8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/pindah_kos_flow/arrow-up-and-down.svg',
                      width: 18,
                      height: 18,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.swap_vert, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Kendaraan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildVehicleOptionCard(
              option: _VehicleOption.motor,
              title: 'Motor',
              subtitle: 'Maksimal 20kg/50kg',
              imagePath: 'assets/pindah_kos_flow/motor.png',
            ),
            if (_selectedVehicle == _VehicleOption.motor) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Pilih kapasitas: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color(0xFF5C6658),
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('20 kg'),
                    selected: _motorSelectedWeight == 20.0,
                    selectedColor: const Color(0xFF263225),
                    labelStyle: TextStyle(
                      color: _motorSelectedWeight == 20.0
                          ? Colors.white
                          : Colors.black,
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                    onSelected: (_) =>
                        setState(() => _motorSelectedWeight = 20.0),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('50 kg'),
                    selected: _motorSelectedWeight == 50.0,
                    selectedColor: const Color(0xFF263225),
                    labelStyle: TextStyle(
                      color: _motorSelectedWeight == 50.0
                          ? Colors.white
                          : Colors.black,
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                    onSelected: (_) =>
                        setState(() => _motorSelectedWeight = 50.0),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            _buildVehicleOptionCard(
              option: _VehicleOption.mobilBoxKecil,
              title: 'Mobil Box Kecil',
              subtitle: 'Maksimal 300kg',
              imagePath: 'assets/pindah_kos_flow/mobil-box-kecil.png',
            ),
            const SizedBox(height: 8),
            _buildVehicleOptionCard(
              option: _VehicleOption.mobilBoxSedang,
              title: 'Mobil Box Sedang',
              subtitle: 'Maksimal 600kg',
              imagePath: 'assets/pindah_kos_flow/mobil-box-sedang.png',
            ),
            const SizedBox(height: 8),
            _buildVehicleOptionCard(
              option: _VehicleOption.mobilBoxBesar,
              title: 'Mobil Box Besar',
              subtitle: 'Maksimal 1000kg',
              imagePath: 'assets/pindah_kos_flow/mobil-box-besar.png',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleOptionCard({
    required _VehicleOption option,
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    final isSelected = _selectedVehicle == option;
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicle = option),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: isSelected ? 1.5 : 0.50,
              color: const Color(0xFF263225),
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          shadows: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  imagePath,
                  width: 48,
                  height: 42,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.local_shipping, size: 36),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: 20,
              height: 20,
              decoration: ShapeDecoration(
                color: isSelected ? const Color(0xFF263225) : Colors.white,
                shape: OvalBorder(
                  side: BorderSide(
                    width: isSelected ? 1.0 : 0.45,
                    color: const Color(0xFF2C2B2B),
                  ),
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi Barang',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 0.50,
                color: Color(0xFF263225),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: _itemDescController,
                maxLines: 3,
                maxLength: 200,
                onChanged: (_) => setState(() {}),
                buildCounter: (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) =>
                    Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '$currentLength/$maxLength',
                    style: const TextStyle(
                      color: Color(0xFFAEABAA),
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                decoration: const InputDecoration(
                  hintText:
                      'Tulisakan detail barang yang akan dipindahkan (opsional)',
                  hintStyle: TextStyle(
                    color: Color(0xFFAEABAA),
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Tanggal dan Waktu',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(
                        width: 0.50,
                        color: Color(0xFF263225),
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/pindah_kos_flow/uil_calender.svg',
                        width: 18,
                        height: 18,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.calendar_today, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _selectedDate != null
                              ? _formatDate(_selectedDate!)
                              : 'Pilih tanggal',
                          style: TextStyle(
                            color: _selectedDate != null
                                ? Colors.black
                                : const Color(0xFF5C6658),
                            fontSize: 12,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(
                        width: 0.50,
                        color: Color(0xFF263225),
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/pindah_kos_flow/mingcute_time-line.svg',
                        width: 18,
                        height: 18,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.access_time, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _selectedTime != null
                              ? _formatTime(_selectedTime!)
                              : 'Pilih waktu',
                          style: TextStyle(
                            color: _selectedTime != null
                                ? Colors.black
                                : const Color(0xFF5C6658),
                            fontSize: 12,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Jenis Barter ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: '(Opsional)',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBarterItem(
                type: BarterType.makanan,
                label: 'Makanan',
                color: const Color(0xFF293EE2),
                iconAsset: 'assets/pindah_kos_flow/sendok-garpu.svg',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBarterItem(
                type: BarterType.barang,
                label: 'Barang',
                color: const Color(0xFFF86F1A),
                iconAsset: 'assets/pindah_kos_flow/barang-putih-filled.svg',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBarterItem(
                type: BarterType.barang,
                label: 'Jasa',
                color: const Color(0xFF23A23F),
                iconAsset: 'assets/pindah_kos_flow/teenyicons_tick-circle-solid.svg',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBarterItem(
                type: BarterType.lainnya,
                label: 'Lainnya',
                color: const Color(0xFF5C6658),
                iconAsset: 'assets/pindah_kos_flow/ph_dots-three-circle-vertical-fill.svg',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 0.50,
                color: Color(0xFF263225),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: TextField(
            controller: _barterDescController,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Plus Jakarta Sans',
            ),
            decoration: const InputDecoration(
              hintText: 'Detail barter yang ditawarkan (misal: Nasi Padang rendang)',
              hintStyle: TextStyle(
                color: Color(0xFFAEABAA),
                fontSize: 12,
                fontFamily: 'Plus Jakarta Sans',
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarterItem({
    required BarterType type,
    required String label,
    required Color color,
    required String iconAsset,
  }) {
    final isSelected = _selectedBarterType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedBarterType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: isSelected ? 1.5 : 0.50,
              color: isSelected ? const Color(0xFF263225) : const Color(0x3F000000),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: ShapeDecoration(
                color: color,
                shape: const OvalBorder(),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconAsset,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.circle, color: Colors.white, size: 16),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
