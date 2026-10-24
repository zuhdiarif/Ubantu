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

class BersihKosInProgressView extends StatefulWidget {
  const BersihKosInProgressView({super.key});

  @override
  State<BersihKosInProgressView> createState() => _BersihKosInProgressViewState();
}

class _BersihKosInProgressViewState extends State<BersihKosInProgressView> {
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
          context.go(AppRouter.bersihKosSelesai);
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
              o.category == ServiceCategory.bersihKos &&
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
          context.go(AppRouter.bersihKosSelesai);
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
      {'title': 'Menyetujui bantuan', 'time': t0},
      {'title': 'Menuju lokasi', 'time': currentStep >= 1 ? t1 : ''},
      {'title': 'Tiba di lokasi', 'time': currentStep >= 2 ? t2 : ''},
      {'title': 'Sedang membersihkan kos', 'time': currentStep >= 3 ? t3 : ''},
      {'title': 'Bantuan selesai', 'time': ''},
    ];

    final bool canShowSos = currentStep >= 1;
    final helperName = activeOrder?.helperId != null ? 'Nasya' : 'Nasya';

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
              _buildHelperCard(context, activeOrder, helperName, hasUnread),
              const SizedBox(height: 20),
              _buildDetailPekerjaanCard(activeOrder),
              const SizedBox(height: 20),
              _buildStatusSection(steps, currentStep),
              if (canShowSos) ...[
                const SizedBox(height: 24),
                _buildSosButton(context),
              ],
              const SizedBox(height: 40),
            ],
          ),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    helperName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Mahasiswa FILKOM UB',
                    style: TextStyle(
                      color: Color(0xFF6C7368),
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.star_rounded, color: Color(0xFFF4A261), size: 16),
                      SizedBox(width: 4),
                      Text(
                        '4.8 (23 ulasan)',
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFE2F1D8),
                    child: Icon(Icons.chat_bubble_rounded, size: 18, color: Color(0xFF263225)),
                  ),
                  onPressed: () {
                    if (activeOrder != null) {
                      context.push(
                        AppRouter.chatRoom,
                        extra: ChatRoomModel(
                          id: activeOrder.id,
                          orderId: activeOrder.id,
                          orderNumber:
                              'UB-${activeOrder.id.length > 4 ? activeOrder.id.substring(0, 4).toUpperCase() : '8890'}',
                          serviceTitle: 'Layanan Bersih Kos',
                          serviceStatus: activeOrder.status.name,
                          otherUserName: helperName,
                          otherUserFaculty: 'Universitas Brawijaya',
                          lastMessage: '',
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
                ),
                if (hasUnread)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF44336),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: ShapeDecoration(
                color: const Color(0xFFF8FAF4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Detail',
                style: TextStyle(
                  color: Color(0xFF263225),
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPekerjaanCard(ServiceOrderModel? activeOrder) {
    final location = activeOrder?.locationOrigin.isNotEmpty == true
        ? activeOrder!.locationOrigin
        : 'Jl. Kaliurang Km 5, Malang (Kos Semula)';
    final desc = activeOrder?.itemDescription.isNotEmpty == true
        ? activeOrder!.itemDescription
        : 'Membersihkan lantai kamar kos, merapikan meja belajar, dan buang sampah.';
    final barter = activeOrder?.barterDescription.isNotEmpty == true
        ? activeOrder!.barterDescription
        : 'Makanan (Nasi Padang rendang + es teh)';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2F1D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
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
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lokasi: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Plus Jakarta Sans')),
              Expanded(
                child: Text(location, style: const TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans')),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pekerjaan: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Plus Jakarta Sans')),
              Expanded(
                child: Text(desc, style: const TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans')),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Barter: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Plus Jakarta Sans')),
              Expanded(
                child: Text(barter, style: const TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans')),
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
          'Status Bantuan',
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
}
