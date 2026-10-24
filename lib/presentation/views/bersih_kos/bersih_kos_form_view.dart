import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/modular_address_card.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

class BersihKosFormView extends StatefulWidget {
  const BersihKosFormView({super.key});

  @override
  State<BersihKosFormView> createState() => _BersihKosFormViewState();
}

class _BersihKosFormViewState extends State<BersihKosFormView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _detailPekerjaanController = TextEditingController();
  final TextEditingController _barterDescController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 3));
  TimeOfDay _selectedTime = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 3)),
  );

  BarterType _selectedBarterType = BarterType.makanan;
  bool _isPhotoUploaded = false;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _detailPekerjaanController.dispose();
    _barterDescController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ServiceOrderProvider>();
    final success = await provider.createBersihKosOrder(
      locationKos: _originController.text.trim(),
      locationDestination: _destinationController.text.trim(),
      jobDetail: _detailPekerjaanController.text.trim(),
      scheduledAt: _selectedDate,
      barterType: _selectedBarterType,
      barterDescription: _barterDescController.text.trim().isEmpty
          ? 'Sesuai kesepakatan'
          : _barterDescController.text.trim(),
      photoUrl: _isPhotoUploaded ? 'https://placehold.co/400x300.png' : null,
    );

    if (!mounted) return;

    if (success) {
      context.push(AppRouter.bersihKosWaiting);
    } else {
      context.push(AppRouter.bersihKosWaiting);
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.bersihKos);
            }
          },
        ),
        title: const Text(
          'Bersih Kos',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLokasiSection(),
                const SizedBox(height: 20),
                _buildDetailPekerjaanSection(),
                const SizedBox(height: 20),
                _buildFotoKondisiSection(),
                const SizedBox(height: 20),
                _buildWaktuSection(),
                const SizedBox(height: 20),
                _buildBarterSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: provider.isLoading ? null : _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF263225),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Meminta Bantuan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLokasiSection() {
    return ModularAddressCard(
      mode: AddressCardMode.single,
      originController: _originController,
      title: 'Lokasi',
      originLabel: 'Lokasi Kos',
      originSubtitle: '(Kos yang Akan Dibersihkan)',
      originHint: 'Masukkan alamat',
      originValidator: (value) =>
          value == null || value.trim().isEmpty ? 'Lokasi kos wajib diisi' : null,
    );
  }

  Widget _buildDetailPekerjaanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Pekerjaan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 0.50, color: Color(0xFF263225)),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFormField(
                controller: _detailPekerjaanController,
                maxLines: 4,
                maxLength: 200,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Plus Jakarta Sans',
                ),
                decoration: const InputDecoration(
                  hintText: 'Tulisakan detail bagian mana yang perlu dibersihkan...',
                  hintStyle: TextStyle(
                    color: Color(0xFFAEABAA),
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                  border: InputBorder.none,
                  counterText: '',
                  isDense: true,
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Detail pekerjaan wajib diisi' : null,
              ),
              Text(
                '${_detailPekerjaanController.text.length}/200',
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

  Widget _buildFotoKondisiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Kondisi Kos (opsional)',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            setState(() {
              _isPhotoUploaded = !_isPhotoUploaded;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: ShapeDecoration(
              color: _isPhotoUploaded ? const Color(0xFFF1F6EC) : Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 0.50,
                  color: _isPhotoUploaded ? const Color(0xFF86B049) : const Color(0xFF263225),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isPhotoUploaded ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                  size: 34,
                  color: _isPhotoUploaded ? const Color(0xFF86B049) : const Color(0xFFAEABAA),
                ),
                const SizedBox(height: 6),
                Text(
                  _isPhotoUploaded ? 'Foto kondisi kos terpilih (1 file)' : 'Upload file',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isPhotoUploaded ? const Color(0xFF263225) : const Color(0xFFAEABAA),
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: _isPhotoUploaded ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaktuSection() {
    final dateStr = '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';
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
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 0.50, color: Color(0xFF263225)),
                      borderRadius: BorderRadius.only(
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
                          fontWeight: FontWeight.w500,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 0.50, color: Color(0xFF263225)),
                      borderRadius: BorderRadius.only(
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
                          fontWeight: FontWeight.w500,
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
    final barterOptions = [
      {'type': BarterType.makanan, 'title': 'Makanan', 'icon': Icons.restaurant_rounded, 'color': const Color(0xFF293EE2)},
      {'type': BarterType.barang, 'title': 'Barang', 'icon': Icons.inventory_2_rounded, 'color': const Color(0xFFF86F1A)},
      {'type': BarterType.lainnya, 'title': 'Jasa', 'icon': Icons.handshake_rounded, 'color': const Color(0xFF23A23F)},
      {'type': BarterType.lainnya, 'title': 'Lainnya', 'icon': Icons.more_horiz_rounded, 'color': const Color(0xFF858585)},
    ];

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
                  color: Color(0xFF6C7368),
                  fontSize: 12,
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
          children: barterOptions.map((opt) {
            final isSelected = _selectedBarterType == opt['type'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedBarterType = opt['type'] as BarterType;
                });
              },
              child: Container(
                width: 76,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF263225) : const Color(0xFFE8EBE4),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: opt['color'] as Color,
                      child: Icon(opt['icon'] as IconData, size: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      opt['title'] as String,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF263225) : Colors.black,
                        fontSize: 12,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _barterDescController,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Plus Jakarta Sans',
          ),
          decoration: InputDecoration(
            hintText: 'Deskripsi barter (misal: Nasi Padang rendang + es teh)',
            hintStyle: const TextStyle(
              color: Color(0xFFAEABAA),
              fontSize: 12,
              fontFamily: 'Plus Jakarta Sans',
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF263225), width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF263225), width: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }
}
