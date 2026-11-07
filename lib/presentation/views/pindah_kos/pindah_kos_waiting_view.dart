import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

class PindahKosWaitingView extends StatefulWidget {
  const PindahKosWaitingView({super.key});

  @override
  State<PindahKosWaitingView> createState() => _PindahKosWaitingViewState();
}

class _PindahKosWaitingViewState extends State<PindahKosWaitingView> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ServiceOrderProvider>();
      final activeOrder = _findActiveOrder(provider);
      if (activeOrder != null && activeOrder.id.isNotEmpty) {
        provider.subscribeToOrder(activeOrder.id);
        _handleStatusTransition(activeOrder.status);
      }
    });
  }

  ServiceOrderModel? _findActiveOrder(ServiceOrderProvider provider) {
    return provider.myOrders
        .where(
          (o) =>
              o.category == ServiceCategory.pindahKos &&
              (o.status == MoveServiceStatus.waiting ||
                  o.status == MoveServiceStatus.accepted ||
                  o.status == MoveServiceStatus.inProgress),
        )
        .firstOrNull ?? (provider.activeOrder?.category == ServiceCategory.pindahKos ? provider.activeOrder : null);
  }

  void _handleStatusTransition(MoveServiceStatus status) {
    if (_hasNavigated || !mounted) return;
    if (status == MoveServiceStatus.accepted ||
        status == MoveServiceStatus.inProgress) {
      _hasNavigated = true;
      context.go(AppRouter.pindahKosInProgress);
    }
  }

  @override
  void dispose() {
    if (!_hasNavigated) {
      try {
        context.read<ServiceOrderProvider>().cancelOrderSubscription();
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceOrderProvider>();
    final activeOrder = _findActiveOrder(provider);

    if (activeOrder != null &&
        (activeOrder.status == MoveServiceStatus.accepted ||
            activeOrder.status == MoveServiceStatus.inProgress)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleStatusTransition(activeOrder.status);
      });
    }

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
          tooltip: 'Kembali',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.home);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 243,
                        height: 243,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: OvalBorder(
                            side: const BorderSide(
                              width: 0.96,
                              color: Color(0xFF263225),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 211,
                        height: 210,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFDBF0DF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(105.50),
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/pindah_kos_flow/illlust-menunggu-bantuan-datang.png',
                            width: 139,
                            height: 107,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.hourglass_top_rounded,
                              size: 60,
                              color: Color(0xFF263225),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        child: Container(
                          width: 19,
                          height: 19,
                          decoration: const ShapeDecoration(
                            color: Color(0xFF263225),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Menunggu bantuan datang',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.20,
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Kami sedang mencari orang terdekat yang siap membantu kamu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.20,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: const Color(0x7FDBF0DF),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 0.50,
                      color: Color(0xFF23A23F),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pastikan lokasi dan detail barang sudah benar agar proses lebih cepat.',
                      style: TextStyle(
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
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Batalkan Permintaan?'),
                        content: const Text(
                          'Apakah kamu yakin ingin membatalkan permintaan pindah kos ini?',
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
                      provider.cancelOrderSubscription();
                      if (activeOrder != null) {
                        await provider.updateStatus(
                          activeOrder.id,
                          MoveServiceStatus.cancelled,
                        );
                      }
                      if (context.mounted) context.pop();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Batalkan Permintaan',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
