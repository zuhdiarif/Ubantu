import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

class BersihKosWaitingView extends StatefulWidget {
  const BersihKosWaitingView({super.key});

  @override
  State<BersihKosWaitingView> createState() => _BersihKosWaitingViewState();
}

class _BersihKosWaitingViewState extends State<BersihKosWaitingView> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final provider = context.read<ServiceOrderProvider>();
      final activeOrder = provider.myOrders
          .where(
            (o) =>
                o.category == ServiceCategory.bersihKos &&
                (o.status == MoveServiceStatus.waiting ||
                    o.status == MoveServiceStatus.accepted ||
                    o.status == MoveServiceStatus.inProgress),
          )
          .firstOrNull;

      if (activeOrder != null && activeOrder.id.isNotEmpty) {
        final updated = await provider.checkOrderStatus(activeOrder.id);
        if (!mounted) return;
        if (updated != null &&
            (updated.status == MoveServiceStatus.accepted ||
                updated.status == MoveServiceStatus.inProgress)) {
          _pollTimer?.cancel();
          context.go(AppRouter.bersihKosInProgress);
        }
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceOrderProvider>();
    final activeOrder = provider.myOrders
        .where(
          (o) =>
              o.category == ServiceCategory.bersihKos &&
              (o.status == MoveServiceStatus.waiting ||
                  o.status == MoveServiceStatus.accepted ||
                  o.status == MoveServiceStatus.inProgress),
        )
        .firstOrNull;

    if (activeOrder != null &&
        (activeOrder.status == MoveServiceStatus.accepted ||
            activeOrder.status == MoveServiceStatus.inProgress)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _pollTimer?.cancel();
          context.go(AppRouter.bersihKosInProgress);
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
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
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.hourglass_top_rounded,
                                size: 80,
                                color: Color(0xFF86B049),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
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
                          side: const BorderSide(
                            width: 0.50,
                            color: Color(0xFFE2F1D8),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                color: Color(0xFF86B049),
                                size: 20,
                              ),
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
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Batalkan Permintaan?'),
                        content: const Text(
                          'Apakah kamu yakin ingin membatalkan permintaan bersih kos ini?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Tidak'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text(
                              'Batalkan',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      _pollTimer?.cancel();
                      if (activeOrder != null) {
                        await provider.updateStatus(
                          activeOrder.id,
                          MoveServiceStatus.cancelled,
                        );
                      }
                      if (context.mounted) {
                        if (Navigator.of(context).canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRouter.bersihKos);
                        }
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFE05252),
                      width: 1.5,
                    ),
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
