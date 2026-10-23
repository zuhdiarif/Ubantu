import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ubantu/core/navigation/app_router.dart';

class PindahKosInProgressView extends StatefulWidget {
  const PindahKosInProgressView({super.key});

  @override
  State<PindahKosInProgressView> createState() =>
      _PindahKosInProgressViewState();
}

class _PindahKosInProgressViewState extends State<PindahKosInProgressView> {
  int _currentStep = 3;

  final List<Map<String, String>> _statusSteps = [
    {'title': 'Menyetujui bantuan', 'time': '10.15'},
    {'title': 'Menuju lokasi', 'time': '10.20'},
    {'title': 'Tiba di lokasi', 'time': '10.30'},
    {'title': 'Saling membantu', 'time': '10.35'},
    {'title': 'Bantuan selesai', 'time': ''},
  ];

  @override
  Widget build(BuildContext context) {
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
          'Bantuan Berlangsung',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildHelperCard(context),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildMapSection(),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildStatusPanel(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelperCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: const Color(0xFF263225),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/pindah_kos_flow/placeholder-user-profile-pic.jpg',
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFFD9D9D9),
                    child: Icon(Icons.person, color: Color(0xFF263225)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Raihan',
                    style: TextStyle(
                      color: Color(0xFFF8FAF4),
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/pindah_kos_flow/bintang-kuning-filled.svg',
                        width: 14,
                        height: 14,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFF86F1A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '4.8 (23)',
                        style: TextStyle(
                          color: Color(0xFFF8FAF4),
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Helper',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Nama: Raihan Lazuardi'),
                      const SizedBox(height: 8),
                      const Text('Fakultas: Ilmu Komputer, Universitas Brawijaya'),
                      const SizedBox(height: 8),
                      const Text('Kendaraan: Honda Beat (N 1234 UB)'),
                      const SizedBox(height: 8),
                      const Text('Verifikasi KTM: Terverifikasi'),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF263225),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Tutup'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: ShapeDecoration(
                color: const Color(0xFFF8FAF4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Detail',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF263225),
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/pindah_kos_flow/placeholder-peta.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFE8EBE4),
              child: const Center(
                child: Icon(Icons.map, size: 48, color: Color(0xFF5C6658)),
              ),
            ),
          ),
        ),
        Positioned(
          left: 60,
          top: 30,
          child: SvgPicture.asset(
            'assets/pindah_kos_flow/path-untuk-placeholder-peta.svg',
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),
        Positioned(
          left: 90,
          top: 50,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const ShapeDecoration(
              color: Color(0xFFF8FAF4),
              shape: OvalBorder(),
            ),
            child: SvgPicture.asset(
              'assets/pindah_kos_flow/ico-motor.svg',
              width: 22,
              height: 22,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.two_wheeler, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPanel(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Bantuan',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  height: 1.20,
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRouter.sosForm),
                    icon: const Icon(
                      Icons.emergency_rounded,
                      color: Colors.red,
                      size: 16,
                    ),
                    label: const Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Membuka chat dengan Raihan...')),
                      );
                    },
                    icon: const Icon(
                      Icons.chat_bubble_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF263225),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: List.generate(_statusSteps.length, (idx) {
              final step = _statusSteps[idx];
              final isDone = idx < _currentStep;
              final isCurrent = idx == _currentStep;
              final isLast = idx == _statusSteps.length - 1;

              return GestureDetector(
                onTap: () => setState(() => _currentStep = idx),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: ShapeDecoration(
                          color: isDone
                              ? const Color(0xFF23A23F)
                              : isCurrent
                                  ? const Color(0xFF263225)
                                  : Colors.white,
                          shape: OvalBorder(
                            side: BorderSide(
                              width: 1.0,
                              color: isDone || isCurrent
                                  ? Colors.transparent
                                  : const Color(0xFF858585),
                            ),
                          ),
                        ),
                        child: Center(
                          child: isDone
                              ? SvgPicture.asset(
                                  'assets/pindah_kos_flow/teenyicons_tick-circle-solid.svg',
                                  width: 14,
                                  height: 14,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                )
                              : isCurrent
                                  ? Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const ShapeDecoration(
                                        color: Colors.white,
                                        shape: OvalBorder(),
                                      ),
                                    )
                                  : null,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 1.5,
                          height: 26,
                          color: isDone
                              ? const Color(0xFF23A23F)
                              : const Color(0xFF858585),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            step['title']!,
                            style: TextStyle(
                              color: isDone || isCurrent
                                  ? Colors.black
                                  : const Color(0xFF858585),
                              fontSize: 12,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              height: 1.20,
                            ),
                          ),
                          if (step['time']!.isNotEmpty)
                            Text(
                              step['time']!,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w400,
                                height: 1.20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                context.push(AppRouter.pindahKosSelesai);
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
                'Selesaikan Bantuan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
