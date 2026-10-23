import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ubantu/core/navigation/app_router.dart';

class BersihKosWaitingView extends StatelessWidget {
  const BersihKosWaitingView({super.key});

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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 220,
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAF4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/pindah_kos_flow/illlust-menunggu-bantuan-datang.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.hourglass_top_rounded,
                                size: 80,
                                color: Color(0xFF86B049),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF263225),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Mencari Helper UB...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Menunggu bantuan datang',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Permintaan bersih kos kamu sedang disiarkan ke mahasiswa UB terdekat. Harap tunggu sebentar hingga ada helper yang menerima.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF6C7368),
                        fontSize: 13,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF8FAF4),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 0.50, color: Color(0xFFE2F1D8)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF86B049), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Tips',
                                style: TextStyle(
                                  color: Color(0xFF263225),
                                  fontSize: 14,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Siapkan peralatan kebersihan (seperti sapu, pel, lap, atau kantong sampah) di depan kamar kos agar helper dapat langsung membersihkan dengan efisien.',
                            style: TextStyle(
                              color: Color(0xFF5C6658),
                              fontSize: 12,
                              fontFamily: 'Plus Jakarta Sans',
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push(AppRouter.bersihKosInProgress),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE2F1D8),
                          foregroundColor: const Color(0xFF263225),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.flash_on_rounded, size: 18),
                        label: const Text(
                          'Simulasi Bantuan Diterima',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRouter.bersihKos);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE05252), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Batalkan Permintaan',
                    style: TextStyle(
                      color: Color(0xFFE05252),
                      fontSize: 15,
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
}
