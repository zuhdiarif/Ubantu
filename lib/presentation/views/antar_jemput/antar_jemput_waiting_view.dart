import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

class AntarJemputWaitingView extends StatefulWidget {
  const AntarJemputWaitingView({super.key});

  @override
  State<AntarJemputWaitingView> createState() => _AntarJemputWaitingViewState();
}

class _AntarJemputWaitingViewState extends State<AntarJemputWaitingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _startPolling();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final provider = context.read<ServiceOrderProvider>();
      final activeOrder = provider.myOrders
          .where(
            (o) =>
                o.category == ServiceCategory.antarJemput &&
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
          context.go(AppRouter.antarJemputInProgress);
        }
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceOrderProvider>();
    final activeOrder = provider.myOrders
        .where(
          (o) =>
              o.category == ServiceCategory.antarJemput &&
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
          context.go(AppRouter.antarJemputInProgress);
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Mencari Helper',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF86B049).withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF263225),
                    ),
                    child: const Icon(
                      Icons.delivery_dining_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Menghubungkan ke Helper...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Permintaanmu sedang disiarkan ke mahasiswa aktif di sekitar area Universitas Brawijaya.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF70776D),
                fontSize: 13,
                fontFamily: 'Plus Jakarta Sans',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            _buildOrderSummaryCard(activeOrder),
            const SizedBox(height: 16),
            _buildTipsCard(),
            const SizedBox(height: 28),
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
                        'Apakah kamu yakin ingin membatalkan permintaan antar jemput ini?',
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
                      Navigator.of(context).pop();
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD3D8D0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Batalkan Permintaan',
                  style: TextStyle(
                    color: Color(0xFF70776D),
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(dynamic activeOrder) {
    final pickup = (activeOrder?.locationOrigin as String?)?.isNotEmpty == true
        ? activeOrder.locationOrigin as String
        : ((activeOrder?.pickupLocation as String?)?.isNotEmpty == true
            ? activeOrder.pickupLocation as String
            : 'Gerbang Utama UB, Jl. Veteran');
    final dest = (activeOrder?.locationDestination as String?)?.isNotEmpty == true
        ? activeOrder.locationDestination as String
        : ((activeOrder?.destinationLocation as String?)?.isNotEmpty == true
            ? activeOrder.destinationLocation as String
            : 'Stasiun Malang Kota Baru');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EBE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan Antar Jemput',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5D9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Estimasi: 3-5 mnt',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4C751F),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFE8EBE4)),
          Row(
            children: [
              const Icon(Icons.my_location_rounded, size: 16, color: Color(0xFF263225)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Jemput: $pickup',
                  style: const TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFF86F1A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tujuan: $dest',
                  style: const TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_rounded, color: Color(0xFF1D4ED8), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Keamanan Mahasiswa',
                  style: TextStyle(
                    color: Color(0xFF1E40AF),
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Periksa kartu mahasiswa (KTM) dan nomor plat kendaraan helper saat bertemu demi keamanan bersama.',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 11,
                    fontFamily: 'Plus Jakarta Sans',
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
