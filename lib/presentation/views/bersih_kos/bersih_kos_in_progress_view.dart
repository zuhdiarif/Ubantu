import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ubantu/core/navigation/app_router.dart';

class BersihKosInProgressView extends StatefulWidget {
  const BersihKosInProgressView({super.key});

  @override
  State<BersihKosInProgressView> createState() => _BersihKosInProgressViewState();
}

class _BersihKosInProgressViewState extends State<BersihKosInProgressView> {
  final int _currentStep = 3;

  final List<String> _steps = [
    'Menyetujui bantuan',
    'Menuju lokasi',
    'Tiba di lokasi',
    'Sedang membersihkan kos',
    'Bantuan selesai',
  ];

  @override
  Widget build(BuildContext context) {
    final bool canShowSos = _currentStep >= 2;

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
          'Bantuan Berlangsung',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelperCard(),
              const SizedBox(height: 20),
              _buildDetailPekerjaanCard(),
              const SizedBox(height: 20),
              _buildStatusSection(),
              if (canShowSos) ...[
                const SizedBox(height: 20),
                _buildSosButton(context),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomButton(context),
    );
  }

  Widget _buildHelperCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2F1D8), width: 1),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/pindah_kos_flow/placeholder-user-profile-pic.jpg',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFE2F1D8),
                child: Icon(Icons.person_rounded, color: Color(0xFF263225), size: 30),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zuhdi Arif',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Mahasiswa FILKOM UB',
                  style: TextStyle(
                    color: Color(0xFF6C7368),
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Color(0xFFF4A261), size: 16),
                    SizedBox(width: 4),
                    Text(
                      '4.9 (24 ulasan)',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE2F1D8),
                  child: Icon(Icons.chat_bubble_rounded, size: 18, color: Color(0xFF263225)),
                ),
                onPressed: () => context.push(AppRouter.chatRoom),
              ),
              IconButton(
                icon: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE2F1D8),
                  child: Icon(Icons.phone_rounded, size: 18, color: Color(0xFF263225)),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPekerjaanCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2F1D8)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cleaning_services_rounded, color: Color(0xFF263225), size: 18),
              SizedBox(width: 8),
              Text(
                'Detail Bantuan Bersih Kos',
                style: TextStyle(
                  color: Color(0xFF263225),
                  fontSize: 13,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lokasi: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Plus Jakarta Sans')),
              Expanded(
                child: Text('Jl. Kaliurang Km 5, Malang (Kos Semula)', style: TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans')),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pekerjaan: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Plus Jakarta Sans')),
              Expanded(
                child: Text('Membersihkan lantai kamar kos, merapikan meja belajar, dan buang sampah.', style: TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans')),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Barter: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Plus Jakarta Sans')),
              Expanded(
                child: Text('Makanan (Nasi Padang rendang + es teh)', style: TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans')),
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
          'Status Bantuan',
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
          'Tekan jika merasa tidak aman selama proses bersih kos.',
          style: TextStyle(
            color: Color(0xFF9B1C1C),
            fontSize: 11,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF9B1C1C), size: 14),
        onTap: () => context.push(AppRouter.sosForm),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.push(AppRouter.bersihKosSelesai),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF263225),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Selesaikan Bantuan',
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
    );
  }
}
