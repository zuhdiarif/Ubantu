import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/chat_room_model.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/presentation/providers/chat_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

class BantuanDetailView extends StatelessWidget {
  final ServiceOrderModel? order;

  const BantuanDetailView({super.key, this.order});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<ServiceOrderProvider>();
    ChatProvider? chatProvider;
    try {
      chatProvider = context.watch<ChatProvider>();
    } catch (_) {}

    final currentOrder = order ??
        orderProvider.myOrders
            .where(
              (o) =>
                  o.status == MoveServiceStatus.accepted ||
                  o.status == MoveServiceStatus.inProgress,
            )
            .firstOrNull ??
        orderProvider.myOrders.firstOrNull;

    final String serviceCategoryName = switch (currentOrder?.category) {
      ServiceCategory.pindahKos => 'Pindah kos',
      ServiceCategory.bersihKos => 'Bersih kos',
      ServiceCategory.antarJemput => 'Antar jemput',
      _ => 'Bersih kos',
    };

    final String helperName = currentOrder?.helperId != null &&
            currentOrder!.helperId!.isNotEmpty
        ? 'Nasya'
        : 'Nasya';

    final String location = currentOrder?.locationOrigin.isNotEmpty == true
        ? currentOrder!.locationOrigin
        : 'Jl. Veteran, Malang';

    final String scheduledDate = currentOrder != null
        ? '${currentOrder.scheduledAt.day} ${_monthName(currentOrder.scheduledAt.month)} ${currentOrder.scheduledAt.year}'
        : '20 Juli 2026';

    final String scheduledTime = currentOrder != null
        ? '${currentOrder.scheduledAt.hour.toString().padLeft(2, '0')}:${currentOrder.scheduledAt.minute.toString().padLeft(2, '0')}'
        : '09:00';

    final String notes = currentOrder?.itemDescription.isNotEmpty == true
        ? currentOrder!.itemDescription
        : 'Bantu bersihkan kamar kos, alat sudah disiapkan';

    final bool hasUnreadForRoom = chatProvider?.hasUnreadMessages ?? false;

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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Detail Petugas',
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF8FAF4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const ShapeDecoration(
                        color: Color(0xFF86B049),
                        shape: OvalBorder(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Status: Aktif',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Informasi Petugas',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/pindah_kos_flow/placeholder-user-profile-pic.jpg',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        width: 64,
                        height: 64,
                        decoration: const ShapeDecoration(
                          color: Color(0xFFD9D9D9),
                          shape: OvalBorder(),
                        ),
                        child: const Icon(Icons.person, color: Color(0xFF263225), size: 36),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        helperName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Color(0xFFF86F1A),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '4.8 (23)',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
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
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF8FAF4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Bantuan',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      label: 'Jenis layanan',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFDBF0DF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          serviceCategoryName,
                          style: const TextStyle(
                            color: Color(0xFF263225),
                            fontSize: 12,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      label: 'Lokasi',
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Color(0xFFF86F1A)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      label: 'Tanggal & jam',
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.black87),
                          const SizedBox(width: 6),
                          Text(
                            scheduledDate,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const ShapeDecoration(
                              color: Color(0xFF202020),
                              shape: OvalBorder(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            scheduledTime,
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
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      label: 'Catatan',
                      child: Text(
                        notes,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFC3BE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'PETA',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (currentOrder != null) {
                            context.push(
                              AppRouter.chatRoom,
                              extra: ChatRoomModel(
                                id: currentOrder.id,
                                orderId: currentOrder.id,
                                orderNumber:
                                    'UB-${currentOrder.id.length > 4 ? currentOrder.id.substring(0, 4).toUpperCase() : '8890'}',
                                serviceTitle: 'Layanan $serviceCategoryName',
                                serviceStatus: currentOrder.status.name,
                                otherUserName: helperName,
                                otherUserFaculty: 'Universitas Brawijaya',
                                lastMessage: '',
                                lastMessageTime: DateTime.now(),
                                itemSummary: currentOrder.itemDescription,
                                pickupLocation: currentOrder.locationOrigin,
                                destinationLocation: currentOrder.locationDestination,
                                totalPrice: currentOrder.barterDescription,
                              ),
                            );
                          } else {
                            context.push(AppRouter.chatRoom);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF263225),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.chat_bubble_rounded, size: 18, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Chat',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            if (hasUnreadForRoom)
                              Positioned(
                                right: 16,
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
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => context.push(AppRouter.sosForm),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFFDEBEB),
                          side: const BorderSide(
                            width: 0.50,
                            color: Color(0xFFF44336),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Bantuan SOS',
                          style: TextStyle(
                            color: Color(0xFFF44336),
                            fontSize: 14,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
    );
  }

  Widget _buildInfoRow({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }

  static String _monthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
