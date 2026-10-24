import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/chat_room_model.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/presentation/providers/chat_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

class AntarJemputInProgressView extends StatefulWidget {
  const AntarJemputInProgressView({super.key});

  @override
  State<AntarJemputInProgressView> createState() => _AntarJemputInProgressViewState();
}

class _AntarJemputInProgressViewState extends State<AntarJemputInProgressView> {
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
                o.category == ServiceCategory.antarJemput &&
                (o.status == MoveServiceStatus.accepted ||
                    o.status == MoveServiceStatus.inProgress ||
                    o.status == MoveServiceStatus.completed),
          )
          .firstOrNull;

      if (activeOrder != null && activeOrder.id.isNotEmpty) {
        final updated = await provider.checkOrderStatus(activeOrder.id);
        if (!mounted) return;
        if (updated != null && updated.status == MoveServiceStatus.completed) {
          _pollTimer?.cancel();
          context.go(AppRouter.antarJemputSelesai);
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
    ChatProvider? chatProvider;
    try {
      chatProvider = context.watch<ChatProvider>();
    } catch (_) {}
    final hasUnread = chatProvider?.hasUnreadMessages ?? false;
    final activeOrder = provider.myOrders
        .where(
          (o) =>
              o.category == ServiceCategory.antarJemput &&
              (o.status == MoveServiceStatus.accepted ||
                  o.status == MoveServiceStatus.inProgress ||
                  o.status == MoveServiceStatus.completed),
        )
        .firstOrNull;

    if (activeOrder != null &&
        activeOrder.status == MoveServiceStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _pollTimer?.cancel();
          context.go(AppRouter.antarJemputSelesai);
        }
      });
    }

    final int currentStep = switch (activeOrder?.status) {
      MoveServiceStatus.accepted => 1,
      MoveServiceStatus.inProgress => 3,
      MoveServiceStatus.completed => 4,
      _ => 1,
    };

    final orderTime = activeOrder?.scheduledAt ?? DateTime.now();
    final t0 = '${orderTime.hour.toString().padLeft(2, '0')}.${orderTime.minute.toString().padLeft(2, '0')}';
    final t1 = '${orderTime.add(const Duration(minutes: 5)).hour.toString().padLeft(2, '0')}.${orderTime.add(const Duration(minutes: 5)).minute.toString().padLeft(2, '0')}';
    final t2 = '${orderTime.add(const Duration(minutes: 15)).hour.toString().padLeft(2, '0')}.${orderTime.add(const Duration(minutes: 15)).minute.toString().padLeft(2, '0')}';
    final t3 = '${orderTime.add(const Duration(minutes: 20)).hour.toString().padLeft(2, '0')}.${orderTime.add(const Duration(minutes: 20)).minute.toString().padLeft(2, '0')}';

    final List<Map<String, String>> steps = [
      {'title': 'Helper menyetujui bantuan', 'time': t0},
      {'title': 'Helper menuju titik jemput', 'time': currentStep >= 1 ? t1 : ''},
      {'title': 'Helper tiba & barang diambil', 'time': currentStep >= 2 ? t2 : ''},
      {'title': 'Sedang dalam perjalanan ke tujuan', 'time': currentStep >= 3 ? t3 : ''},
      {'title': 'Tiba di tujuan & selesai', 'time': ''},
    ];

    final helperName = activeOrder?.helperId != null ? 'Nasya' : 'Nasya';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelperCard(context, activeOrder, helperName, hasUnread),
            const SizedBox(height: 16),
            _buildTripDetailCard(activeOrder),
            const SizedBox(height: 18),
            _buildStatusSection(steps, currentStep),
            const SizedBox(height: 20),
            _buildSosButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHelperCard(
    BuildContext context,
    ServiceOrderModel? activeOrder,
    String helperName,
    bool hasUnread,
  ) {
    return InkWell(
      onTap: () {
        context.push(AppRouter.bantuanDetail, extra: activeOrder);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                ClipOval(
                  child: Image.asset(
                    'assets/pindah_kos_flow/placeholder-user-profile-pic.jpg',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFF263225),
                      child: Text(
                        'NS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
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
                          Text(
                            helperName,
                            style: const TextStyle(
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
                        'Teknik Mesin FT UB • Honda Beat',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF70776D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.star_rounded, size: 16, color: Color(0xFFFACA15)),
                          SizedBox(width: 2),
                          Text(
                            '4.8 (23 bantuan selesai)',
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
                  child: OutlinedButton(
                    onPressed: () {
                      if (activeOrder != null) {
                        context.push(
                          AppRouter.chatRoom,
                          extra: ChatRoomModel(
                            id: 'room_${activeOrder.id}',
                            orderId: activeOrder.id,
                            orderNumber:
                                'UB-${activeOrder.id.length > 4 ? activeOrder.id.substring(0, 4).toUpperCase() : '8890'}',
                            serviceTitle: 'Layanan Antar Jemput',
                            serviceStatus: activeOrder.status.name,
                            otherUserName: helperName,
                            otherUserFaculty: 'Universitas Brawijaya',
                            lastMessage: 'Halo! Saya petugas yang membantu Anda.',
                            lastMessageTime: DateTime.now(),
                            itemSummary: activeOrder.itemDescription,
                            pickupLocation: activeOrder.locationOrigin,
                            destinationLocation: activeOrder.locationDestination,
                            totalPrice: activeOrder.barterDescription,
                          ),
                        );
                      } else {
                        context.push(AppRouter.chatRoom);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF263225),
                      side: const BorderSide(color: Color(0xFF263225)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                        const SizedBox(width: 6),
                        const Text('Chat Helper'),
                        if (hasUnread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF44336),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push(AppRouter.bantuanDetail, extra: activeOrder);
                    },
                    icon: const Icon(Icons.info_outline_rounded, size: 16),
                    label: const Text('Detail Petugas'),
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
      ),
    );
  }

  Widget _buildTripDetailCard(ServiceOrderModel? activeOrder) {
    final pickup = activeOrder?.locationOrigin.isNotEmpty == true
        ? activeOrder!.locationOrigin
        : 'Gerbang Utama UB, Jl. Veteran';
    final dest = activeOrder?.locationDestination.isNotEmpty == true
        ? activeOrder!.locationDestination
        : 'Stasiun Malang Kota Baru';
    final barter = activeOrder?.barterDescription.isNotEmpty == true
        ? activeOrder!.barterDescription
        : 'Makanan (Nasi Padang)';
    final orderNum = activeOrder != null && activeOrder.id.length > 4
        ? 'Order #UB-${activeOrder.id.substring(0, 4).toUpperCase()}'
        : 'Order #AJ-UB-2026';

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
              Expanded(
                child: Text(
                  'Titik Jemput: $pickup',
                  style: const TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans'),
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
              Expanded(
                child: Text(
                  'Tujuan: $dest',
                  style: const TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans'),
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFE8EBE4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Barter: $barter',
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4C751F),
                ),
              ),
              Text(
                orderNum,
                style: const TextStyle(
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

  Widget _buildStatusSection(List<Map<String, String>> steps, int currentStep) {
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
        ...List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          final isLast = index == steps.length - 1;
          final step = steps[index];

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step['title']!,
                        style: TextStyle(
                          color: isCompleted || isCurrent ? Colors.black : const Color(0xFFA5ACA1),
                          fontSize: 13,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: isCurrent ? FontWeight.w700 : (isCompleted ? FontWeight.w600 : FontWeight.w400),
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
                          ),
                        ),
                    ],
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
}
