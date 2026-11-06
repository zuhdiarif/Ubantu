import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/loyalty_provider.dart';
import 'package:ubantu/presentation/providers/rating_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

class BersihKosSelesaiView extends StatefulWidget {
  const BersihKosSelesaiView({super.key});

  @override
  State<BersihKosSelesaiView> createState() => _BersihKosSelesaiViewState();
}

class _BersihKosSelesaiViewState extends State<BersihKosSelesaiView> {
  int _rating = 5;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final ratingProvider = context.read<RatingProvider>();
    final orderProvider = context.read<ServiceOrderProvider>();
    final authProvider = context.read<AuthProvider>();
    final loyaltyProvider = context.read<LoyaltyProvider>();
    final activeOrder = orderProvider.activeOrder;
    final helperId = activeOrder?.helperId ?? '';
    final review = _reviewController.text.trim().isEmpty
        ? 'Kamar kos dibersihkan dengan sangat rapi dan tepat waktu!'
        : _reviewController.text.trim();

    if (helperId.isNotEmpty) {
      await ratingProvider.submitRating(
        helperId,
        _rating.toDouble(),
        review,
      );
    }

    try {
      final user = authProvider.currentUser;
      if (user != null && user.id.isNotEmpty) {
        final orderId = activeOrder?.id;
        if (orderId != null && orderId.isNotEmpty) {
          await loyaltyProvider.awardOrderPoints(user.id, orderId);
        }
      }
    } catch (_) {}

    if (!mounted) return;
    context.go(AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<ServiceOrderProvider>();
    final activeOrder = orderProvider.activeOrder;

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
              context.go(AppRouter.home);
            }
          },
        ),
        title: const Text(
          'Bantuan Selesai',
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2F1D8),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF263225),
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Terimakasih!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bantuan bersih kos telah selesai.\nSemoga pengalaman saling membantu ini menyenangkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6C7368),
                  fontSize: 13,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2F1D8)),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFF86B049),
                      child: Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '+10 Poin UBantu Ditambahkan!',
                            style: TextStyle(
                              color: Color(0xFF263225),
                              fontSize: 13,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Kumpulkan poin untuk menukar voucher barter gratis.',
                            style: TextStyle(
                              color: Color(0xFF5C6658),
                              fontSize: 11,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildProofPhotoCard(context, activeOrder?.completionPhotoUrl),
              _buildBarterConfirmationCard(context, orderProvider, activeOrder),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFE8EBE4), width: 1),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Berikan ulasan untuk helper',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starNum = index + 1;
                        return IconButton(
                          icon: Icon(
                            starNum <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: const Color(0xFFF4A261),
                            size: 36,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = starNum;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _reviewController,
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tuliskan kesan atau ulasan singkat...',
                        hintStyle: const TextStyle(
                          color: Color(0xFFAEABAA),
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF263225), width: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF263225), width: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF263225),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProofPhotoCard(BuildContext context, String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    final isNetwork = photoUrl.startsWith('http://') || photoUrl.startsWith('https://');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF86B049),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Bukti Penyelesaian dari Mitra',
                style: TextStyle(
                  color: Color(0xFF263225),
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showFullScreenPhoto(context, photoUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  isNetwork
                      ? Image.network(
                          photoUrl,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              height: 180,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF86B049),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                            ),
                          ),
                        )
                      : Image.file(
                          File(photoUrl),
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                            ),
                          ),
                        ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Ketuk untuk perbesar',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenPhoto(BuildContext context, String photoUrl) {
    final isNetwork = photoUrl.startsWith('http://') || photoUrl.startsWith('https://');
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: isNetwork
                    ? Image.network(photoUrl)
                    : Image.file(File(photoUrl)),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarterConfirmationCard(
    BuildContext context,
    ServiceOrderProvider orderProvider,
    ServiceOrderModel? activeOrder,
  ) {
    if (activeOrder == null) return const SizedBox.shrink();

    final isConfirmed = activeOrder.barterConfirmedByCustomer;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConfirmed ? const Color(0xFFF1F6EA) : const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConfirmed
              ? const Color(0xFF86B049).withValues(alpha: 0.4)
              : const Color(0xFFF4A261).withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConfirmed ? Icons.check_circle_rounded : Icons.help_outline_rounded,
                color: isConfirmed ? const Color(0xFF86B049) : const Color(0xFFF4A261),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Konfirmasi Penerimaan Imbalan / Barter',
                  style: TextStyle(
                    color: Color(0xFF263225),
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Imbalan yang disepakati: "${activeOrder.barterDescription}"',
            style: const TextStyle(
              color: Color(0xFF5C6658),
              fontSize: 12,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Imbalan/Barter sudah diterima mitra?',
            style: TextStyle(
              color: Color(0xFF263225),
              fontSize: 12,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          if (isConfirmed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDEF7EC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 14, color: Color(0xFF0E9F6E)),
                  SizedBox(width: 6),
                  Text(
                    'Imbalan sudah dikonfirmasi telah diterima',
                    style: TextStyle(
                      color: Color(0xFF0E9F6E),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF263225),
                side: const BorderSide(color: Color(0xFF263225)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text(
                'Sudah Diterima Mitra',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await orderProvider.confirmBarter(activeOrder.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Konfirmasi penerimaan barter berhasil disimpan!'),
                      backgroundColor: Color(0xFF86B049),
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
