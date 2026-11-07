import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/loyalty_provider.dart';
import 'package:ubantu/presentation/providers/rating_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

class PindahKosSelesaiView extends StatefulWidget {
  const PindahKosSelesaiView({super.key});

  @override
  State<PindahKosSelesaiView> createState() => _PindahKosSelesaiViewState();
}

class _PindahKosSelesaiViewState extends State<PindahKosSelesaiView> {
  int _rating = 5;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final orderProvider = context.read<ServiceOrderProvider>();
    final ratingProvider = context.read<RatingProvider>();
    final authProvider = context.read<AuthProvider>();
    final loyaltyProvider = context.read<LoyaltyProvider>();
    final activeOrder = orderProvider.activeOrder;
    final helperId = activeOrder?.helperId ?? '';
    final reviewText = _reviewController.text.trim();

    if (helperId.isNotEmpty && reviewText.isNotEmpty) {
      await ratingProvider.submitRating(
        helperId,
        _rating.toDouble(),
        reviewText,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E281C),
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
              SvgPicture.asset(
                'assets/pindah_kos_flow/bi_check-circle-fill.svg',
                width: 90,
                height: 90,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF23A23F),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Terimakasih!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.20,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bantuan telah selesai.\nSemoga pengalamanmu menyenangkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.20,
                ),
              ),
              const SizedBox(height: 20),
              _buildProofPhotoCard(context, activeOrder?.completionPhotoUrl),
              _buildBarterConfirmationCard(context, orderProvider, activeOrder),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Berikan ulasan',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                        height: 1.20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'untuk ${(activeOrder?.helperName != null && activeOrder!.helperName!.isNotEmpty) ? activeOrder.helperName! : 'Mitra Penolong UB'}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                        height: 1.20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starNumber = index + 1;
                        final isFilled = starNumber <= _rating;
                        return GestureDetector(
                          onTap: () => setState(() => _rating = starNumber),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: SvgPicture.asset(
                              isFilled
                                  ? 'assets/pindah_kos_flow/bintang-kuning-filled.svg'
                                  : 'assets/pindah_kos_flow/material-symbols_star-rounded.svg',
                              width: 34,
                              height: 34,
                              colorFilter: isFilled
                                  ? null
                                  : const ColorFilter.mode(
                                      Color(0xFFD9D9D9),
                                      BlendMode.srcIn,
                                    ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 0.50,
                            color: Color(0xFF263225),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _reviewController,
                            maxLines: 4,
                            maxLength: 200,
                            onChanged: (_) => setState(() {}),
                            buildCounter: (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) =>
                                Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                '$currentLength/$maxLength',
                                style: const TextStyle(
                                  color: Color(0xFFBFC3BE),
                                  fontSize: 12,
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Tulis ulasan kamu (opsional)',
                              hintStyle: TextStyle(
                                color: Color(0xFFBFC3BE),
                                fontSize: 12,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
                    'Selesai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
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
