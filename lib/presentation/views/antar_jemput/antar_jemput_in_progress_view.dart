import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ubantu/core/navigation/app_router.dart';

class AntarJemputInProgressView extends StatefulWidget {
  const AntarJemputInProgressView({super.key});

  @override
  State<AntarJemputInProgressView> createState() => _AntarJemputInProgressViewState();
}

class _AntarJemputInProgressViewState extends State<AntarJemputInProgressView> {
  final int _currentStep = 3;

  final List<String> _steps = [
    'Helper menyetujui bantuan',
    'Helper menuju titik jemput',
    'Helper tiba & barang diambil',
    'Sedang dalam perjalanan ke tujuan',
    'Tiba di tujuan & selesai',
  ];

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
          'Bantuan Berlangsung',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelperCard(context),
                const SizedBox(height: 16),
                _buildTripDetailCard(),
                const SizedBox(height: 18),
                _buildStatusSection(),
                const SizedBox(height: 20),
                _buildSosButton(context),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHelperCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EBE4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFF263225),
                child: Text(
                  'AR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Ahmad Rizky',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDEF7EC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 12, color: Color(0xFF0E9F6E)),
                              SizedBox(width: 2),
                              Text(
                                'KTM UB',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0E9F6E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Teknik Mesin FT UB • Honda Vario (N 4567 UB)',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF70776D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: Color(0xFFFACA15)),
                        SizedBox(width: 2),
                        Text(
                          '4.9 (38 bantuan selesai)',
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFE8EBE4)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Membuka percakapan chat dengan Ahmad Rizky...')),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  label: const Text('Chat Helper'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF263225),
                    side: const BorderSide(color: Color(0xFF263225)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menghubungkan panggilan ke helper...')),
                    );
                  },
                  icon: const Icon(Icons.phone_outlined, size: 16),
                  label: const Text('Telepon'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF263225),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetailCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EBE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Pengantaran',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.my_location_rounded, size: 16, color: Color(0xFF263225)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Titik Jemput: Gerbang Utama UB, Jl. Veteran',
                  style: TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFF86F1A)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tujuan: Stasiun Malang Kota Baru',
                  style: TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans'),
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFE8EBE4)),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Barter: Makanan (Nasi Padang)',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4C751F),
                ),
              ),
              Text(
                'Order #AJ-UB-2026',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFF70776D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Pengantaran',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(_steps.length, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          final isLast = index == _steps.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isCompleted
                        ? const Color(0xFF86B049)
                        : (isCurrent ? const Color(0xFF263225) : const Color(0xFFE8EBE4)),
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                        : (isCurrent
                            ? const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF6C7368),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 24,
                      color: isCompleted ? const Color(0xFF86B049) : const Color(0xFFE8EBE4),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 2, bottom: isLast ? 0 : 16),
                  child: Text(
                    _steps[index],
                    style: TextStyle(
                      color: isCompleted || isCurrent ? Colors.black : const Color(0xFFA5ACA1),
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: isCurrent ? FontWeight.w700 : (isCompleted ? FontWeight.w600 : FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSosButton(BuildContext context) {
    return Material(
      color: const Color(0xFFFDE8E8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF05252)),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE02424),
          child: Icon(Icons.sos_rounded, color: Colors.white, size: 24),
        ),
        title: const Text(
          'Tombol Darurat (SOS)',
          style: TextStyle(
            color: Color(0xFF9B1C1C),
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: const Text(
          'Tekan jika terjadi situasi tidak aman selama perjalanan.',
          style: TextStyle(
            color: Color(0xFF9B1C1C),
            fontSize: 11,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF9B1C1C), size: 16),
        onTap: () {
          context.push(AppRouter.sosForm);
        },
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
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
          onPressed: () {
            context.push(AppRouter.antarJemputSelesai);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF263225),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Konfirmasi Selesai & Beri Ulasan',
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
