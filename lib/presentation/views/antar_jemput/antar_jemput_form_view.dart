import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

class AntarJemputFormView extends StatefulWidget {
  const AntarJemputFormView({super.key});

  @override
  State<AntarJemputFormView> createState() => _AntarJemputFormViewState();
}

class _AntarJemputFormViewState extends State<AntarJemputFormView> {
  final TextEditingController _originController = TextEditingController(text: 'Gerbang Utama UB, Jl. Veteran');
  final TextEditingController _destinationController = TextEditingController(text: 'Stasiun Malang Kota Baru');
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _barterDescController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 30);

  String _mode = 'barang';
  VehicleType _selectedVehicle = VehicleType.motor;
  double _selectedWeight = 5.0;

  BarterType _selectedBarter = BarterType.makanan;
  bool _isPhotoUploaded = false;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _detailController.dispose();
    _barterDescController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF263225),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF263225),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitOrder() async {
    if (_originController.text.trim().isEmpty || _destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi jemput dan tujuan wajib diisi.')),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final provider = context.read<ServiceOrderProvider>();

    final success = await provider.createAntarJemputOrder(
      locationOrigin: _originController.text.trim(),
      locationDestination: _destinationController.text.trim(),
      itemDescription: _detailController.text.trim().isEmpty
          ? (_mode == 'barang' ? 'Pengiriman barang seputar UB' : 'Tebengan antar mahasiswa UB')
          : _detailController.text.trim(),
      scheduledAt: scheduledDateTime,
      barterType: _selectedBarter,
      barterDescription: _barterDescController.text.trim().isEmpty
          ? 'Barter standar ${_selectedBarter.name}'
          : _barterDescController.text.trim(),
      vehicleType: _selectedVehicle,
      weightKg: _mode == 'barang' ? _selectedWeight : null,
      photoUrl: _isPhotoUploaded ? 'https://placehold.co/400x300.png' : null,
    );

    if (!mounted) return;

    if (success) {
      context.push(AppRouter.antarJemputWaiting);
    } else {
      context.push(AppRouter.antarJemputWaiting);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Antar Jemput',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
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
                const SizedBox(height: 14),
                _buildModeSelector(),
                const SizedBox(height: 16),
                _buildLocationSection(),
                const SizedBox(height: 16),
                _buildVehicleAndWeightSection(),
                const SizedBox(height: 16),
                _buildJobDetailSection(),
                const SizedBox(height: 16),
                _buildPhotoUploadSection(),
                const SizedBox(height: 16),
                _buildDateTimeSection(),
                const SizedBox(height: 16),
                _buildBarterSection(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4ED),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _mode = 'barang'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _mode == 'barang' ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _mode == 'barang'
                      ? [const BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      size: 16,
                      color: _mode == 'barang' ? const Color(0xFF263225) : const Color(0xFF70776D),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Kirim Barang',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: _mode == 'barang' ? FontWeight.w700 : FontWeight.w500,
                        color: _mode == 'barang' ? const Color(0xFF263225) : const Color(0xFF70776D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _mode = 'tebengan'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _mode == 'tebengan' ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _mode == 'tebengan'
                      ? [const BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_pin_circle_rounded,
                      size: 16,
                      color: _mode == 'tebengan' ? const Color(0xFF263225) : const Color(0xFF70776D),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tebengan / Orang',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: _mode == 'tebengan' ? FontWeight.w700 : FontWeight.w500,
                        color: _mode == 'tebengan' ? const Color(0xFF263225) : const Color(0xFF70776D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
        const SizedBox(height: 10),
        _buildLocationInputCard(
          tag: 'Dari',
          subtitle: '(Titik Jemput)',
          controller: _originController,
          icon: Icons.my_location_rounded,
          iconColor: const Color(0xFF263225),
        ),
        const SizedBox(height: 10),
        _buildLocationInputCard(
          tag: 'Ke',
          subtitle: '(Titik Tujuan / Antar)',
          controller: _destinationController,
          icon: Icons.location_on_rounded,
          iconColor: const Color(0xFFF86F1A),
        ),
      ],
    );
  }

  Widget _buildLocationInputCard({
    required String tag,
    required String subtitle,
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.8, color: Color(0xFFD3D8D0)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: iconColor.withValues(alpha: 0.12),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF70776D),
                        fontSize: 11,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 4, bottom: 2),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleAndWeightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilihan Kendaraan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildVehicleOptionCard(
                vehicle: VehicleType.motor,
                title: 'Motor',
                subtitle: 'Cepat & lincah (Max 10 kg)',
                icon: Icons.two_wheeler_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVehicleOptionCard(
                vehicle: VehicleType.mobil,
                title: 'Mobil',
                subtitle: 'Muat banyak (Max 15 kg)',
                icon: Icons.directions_car_rounded,
              ),
            ),
          ],
        ),
        if (_mode == 'barang') ...[
          const SizedBox(height: 14),
          const Text(
            'Kategori Berat Barang',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildWeightChips(),
        ],
      ],
    );
  }

  Widget _buildVehicleOptionCard({
    required VehicleType vehicle,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedVehicle == vehicle;
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicle = vehicle),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F6EA) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF263225) : const Color(0xFFE8EBE4),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isSelected ? const Color(0xFF263225) : const Color(0xFFE8EBE4),
              child: Icon(icon, color: isSelected ? Colors.white : const Color(0xFF70776D), size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color(0xFF70776D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChips() {
    final weights = _selectedVehicle == VehicleType.motor
        ? [
            {'label': '< 3 kg (Ringan)', 'val': 3.0},
            {'label': '5 kg (Sedang)', 'val': 5.0},
            {'label': '10 kg (Maksimal)', 'val': 10.0},
          ]
        : [
            {'label': '5 kg', 'val': 5.0},
            {'label': '10 kg', 'val': 10.0},
            {'label': '15 kg (Maksimal)', 'val': 15.0},
          ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: weights.map((w) {
        final val = w['val'] as double;
        final label = w['label'] as String;
        final isSelected = _selectedWeight == val;

        return ChoiceChip(
          label: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          selected: isSelected,
          selectedColor: const Color(0xFF263225),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? const Color(0xFF263225) : const Color(0xFFD3D8D0),
            ),
          ),
          onSelected: (selected) {
            if (selected) setState(() => _selectedWeight = val);
          },
        );
      }).toList(),
    );
  }

  Widget _buildJobDetailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _mode == 'barang' ? 'Detail Barang / Paket' : 'Catatan Penjemputan',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 0.8, color: Color(0xFF263225)),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _detailController,
                maxLength: 200,
                maxLines: 3,
                style: const TextStyle(fontSize: 13, fontFamily: 'Plus Jakarta Sans'),
                decoration: InputDecoration(
                  hintText: _mode == 'barang'
                      ? 'Tuliskan jenis barang (contoh: buku laporan, baju, titipan makanan)...'
                      : 'Tuliskan ciri pakaian atau titik tunggu spesifik...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFAEABAA),
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                  border: InputBorder.none,
                  counterText: '',
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              Text(
                '${_detailController.text.length}/200',
                style: const TextStyle(
                  color: Color(0xFFAEABAA),
                  fontSize: 11,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Barang / Titipan (opsional)',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            setState(() {
              _isPhotoUploaded = !_isPhotoUploaded;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isPhotoUploaded
                      ? 'Foto barang berhasil dipilih!'
                      : 'Foto barang dihapus.',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: ShapeDecoration(
              color: _isPhotoUploaded ? const Color(0xFFF1F6EA) : Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 0.8,
                  color: _isPhotoUploaded ? const Color(0xFF23A23F) : const Color(0xFF263225),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _isPhotoUploaded ? const Color(0xFF23A23F) : const Color(0xFFF0F4ED),
                  child: Icon(
                    _isPhotoUploaded ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                    color: _isPhotoUploaded ? Colors.white : const Color(0xFF263225),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isPhotoUploaded ? 'Foto barang terlampir (Klik untuk ubah)' : 'Upload foto barang',
                  style: TextStyle(
                    color: _isPhotoUploaded ? const Color(0xFF23A23F) : const Color(0xFF70776D),
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: _isPhotoUploaded ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    final dateStr = '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
    final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

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
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _pickDate,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 0.8, color: Color(0xFF263225)),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF263225)),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(width: 1, height: 44, color: const Color(0xFF263225)),
            Expanded(
              child: InkWell(
                onTap: _pickTime,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 0.8, color: Color(0xFF263225)),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF263225)),
                      const SizedBox(width: 8),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
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
                  color: Color(0xFF70776D),
                  fontSize: 13,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBarterCard(
              type: BarterType.makanan,
              title: 'Makanan',
              icon: Icons.fastfood_rounded,
              color: const Color(0xFF293EE2),
            ),
            _buildBarterCard(
              type: BarterType.barang,
              title: 'Barang',
              icon: Icons.inventory_2_rounded,
              color: const Color(0xFFF86F1A),
            ),
            _buildBarterCard(
              type: BarterType.lainnya,
              title: 'Jasa',
              icon: Icons.volunteer_activism_rounded,
              color: const Color(0xFF23A23F),
            ),
            _buildBarterCard(
              type: BarterType.lainnya,
              title: 'Lainnya',
              icon: Icons.more_horiz_rounded,
              color: const Color(0xFF6C7368),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8EBE4)),
          ),
          child: TextField(
            controller: _barterDescController,
            style: const TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans'),
            decoration: const InputDecoration(
              hintText: 'Keterangan barang/makanan barter (misal: Nasi Padang / Pulsa)...',
              hintStyle: TextStyle(fontSize: 11, color: Color(0xFFA5ACA1)),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarterCard({
    required BarterType type,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedBarter == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedBarter = type),
      child: Container(
        width: 74,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF263225) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _submitOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF263225),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Meminta Bantuan',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
