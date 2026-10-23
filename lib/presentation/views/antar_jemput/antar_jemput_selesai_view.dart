import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ubantu/core/navigation/app_router.dart';

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

  void _submitReview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ulasan berhasil dikirim! Terima kasih.')),
    );
    context.go(AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 24),
            _buildRatingSection(),
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

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Beri Penilaian untuk Ahmad Rizky',
          style: TextStyle(
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
