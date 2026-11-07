import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/data/models/service_order_model.dart';
import 'package:ubantu/ui/auth/auth_provider.dart';
import 'package:ubantu/ui/profile/loyalty_provider.dart';
import 'package:ubantu/ui/mitra/rating_provider.dart';
import 'package:ubantu/ui/aktivitas/service_order_provider.dart';

class AntarJemputSelesaiView extends StatefulWidget {
  const AntarJemputSelesaiView({super.key});

  @override
  State<AntarJemputSelesaiView> createState() => _AntarJemputSelesaiViewState();
}

class _AntarJemputSelesaiViewState extends State<AntarJemputSelesaiView> {
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
    final reviewText = _reviewController.text.trim();

    final effectiveHelperId = helperId.isNotEmpty ? helperId : 'mitra_ub_default';
    final review = reviewText.isNotEmpty
        ? reviewText
        : 'Pelayanan sangat baik dan memuaskan!';
    try {
      await ratingProvider.submitRating(
        effectiveHelperId,
        _rating.toDouble(),
        review,
      );
    } catch (_) {}

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ulasan berhasil dikirim! Terima kasih.')),
    );
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
          icon: const Icon(Icons.close_rounded, color: Colors.black, size: 24),
          onPressed: () => context.go(AppRouter.home),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDEF7EC),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF0E9F6E),
                size: 50,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Pengantaran Selesai!',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Terima kasih telah saling membantu antar sesama mahasiswa Universitas Brawijaya.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF70776D),
                fontSize: 13,
                fontFamily: 'Plus Jakarta Sans',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            _buildRewardPointsCard(),
            const SizedBox(height: 20),
            _buildProofPhotoCard(context, activeOrder?.completionPhotoUrl),
            _buildBarterConfirmationCard(context, orderProvider, activeOrder),
            const SizedBox(height: 8),
            _buildRatingSection(activeOrder),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF263225),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Kirim Ulasan & Selesai',
                  style: TextStyle(
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

  Widget _buildRewardPointsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6EA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF86B049).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF86B049),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+10 Poin Barter UBantu',
                  style: TextStyle(
                    color: Color(0xFF263225),
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Poin bertambah! Tukarkan dengan reward makanan atau bantuan berikutnya.',
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
    );
  }

  Widget _buildRatingSection(ServiceOrderModel? order) {
    final helperName = (order?.helperName != null && order!.helperName!.isNotEmpty)
        ? order.helperName!
        : 'Mitra Penolong UB';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Beri Penilaian untuk $helperName',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            return IconButton(
              iconSize: 32,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              icon: Icon(
                starNumber <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                color: starNumber <= _rating ? const Color(0xFFFACA15) : const Color(0xFFD3D8D0),
              ),
              onPressed: () {
                setState(() {
                  _rating = starNumber;
                });
              },
            );
          }),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8EBE4)),
          ),
          child: TextField(
            controller: _reviewController,
            maxLines: 3,
            style: const TextStyle(fontSize: 12, fontFamily: 'Plus Jakarta Sans'),
            decoration: const InputDecoration(
              hintText: 'Tuliskan ulasan untuk helper (misal: tepat waktu, aman, ramah)...',
              hintStyle: TextStyle(fontSize: 11, color: Color(0xFFA5ACA1)),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}
