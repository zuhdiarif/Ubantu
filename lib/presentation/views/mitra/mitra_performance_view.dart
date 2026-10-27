import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';
import 'package:ubantu/presentation/providers/rating_provider.dart';

class MitraPerformanceView extends StatefulWidget {
  const MitraPerformanceView({super.key});

  @override
  State<MitraPerformanceView> createState() => _MitraPerformanceViewState();
}

class _MitraPerformanceViewState extends State<MitraPerformanceView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final mitra = context.read<MitraProvider>().profile;
        final targetId = mitra?.userId ?? mitra?.id;
        if (targetId != null && targetId.isNotEmpty) {
          try {
            context.read<RatingProvider>().loadRatings(targetId);
          } catch (_) {}
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MitraProvider>();
    final profile = provider.profile;
    final rating = profile?.rating ?? 4.9;
    final totalReviews = profile?.totalReviews ?? 38;
    final totalCompleted = profile?.totalOrdersCompleted ?? 42;
    final acceptanceRate = profile?.acceptanceRate ?? 98.0;

    RatingProvider? ratingProvider;
    try {
      ratingProvider = context.watch<RatingProvider>();
    } catch (_) {}
    final ratings = ratingProvider?.ratings ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Performa & Ulasan Mitra',
          style: AppTypography.h5.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreHeroCard(
              context,
              rating,
              totalReviews,
              totalCompleted,
              ratings,
            ),
            const SizedBox(height: 16),
            _buildMetricsRow(totalCompleted, acceptanceRate),
            const SizedBox(height: 20),
            Text(
              'Ulasan Mahasiswa UB',
              style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildReviewsList(context, ratings),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreHeroCard(
    BuildContext context,
    double rating,
    int totalReviews,
    int totalCompleted,
    List<dynamic> ratings,
  ) {
    double r5 = 0.92;
    double r4 = 0.08;
    double r3 = 0.0;
    double r2 = 0.0;
    double r1 = 0.0;
    String p5 = '92%';
    String p4 = '8%';
    String p3 = '0%';
    String p2 = '0%';
    String p1 = '0%';

    if (ratings.isNotEmpty) {
      final int tot = ratings.length;
      final int c5 = ratings.where((r) => r.score >= 4.5).length;
      final int c4 =
          ratings.where((r) => r.score >= 3.5 && r.score < 4.5).length;
      final int c3 =
          ratings.where((r) => r.score >= 2.5 && r.score < 3.5).length;
      final int c2 =
          ratings.where((r) => r.score >= 1.5 && r.score < 2.5).length;
      final int c1 = ratings.where((r) => r.score < 1.5).length;

      r5 = c5 / tot;
      r4 = c4 / tot;
      r3 = c3 / tot;
      r2 = c2 / tot;
      r1 = c1 / tot;
      p5 = '${(r5 * 100).toInt()}%';
      p4 = '${(r4 * 100).toInt()}%';
      p3 = '${(r3 * 100).toInt()}%';
      p2 = '${(r2 * 100).toInt()}%';
      p1 = '${(r1 * 100).toInt()}%';
    } else if (SupabaseService.instance.isInitialized) {
      r5 = 0.0;
      r4 = 0.0;
      r3 = 0.0;
      r2 = 0.0;
      r1 = 0.0;
      p5 = '0%';
      p4 = '0%';
      p3 = '0%';
      p2 = '0%';
      p1 = '0%';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$rating',
                        style: AppTypography.display.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ 5.0',
                        style: AppTypography.body1.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Berdasarkan $totalReviews ulasan mahasiswa',
                    style: AppTypography.caption.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySage.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  size: 44,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          _buildRatingBar('5 Bintang', r5, p5),
          _buildRatingBar('4 Bintang', r4, p4),
          _buildRatingBar('3 Bintang', r3, p3),
          _buildRatingBar('2 Bintang', r2, p2),
          _buildRatingBar('1 Bintang', r1, p1),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, double ratio, String percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: Colors.grey.shade200,
                color: Colors.amber,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 32,
            child: Text(
              percent,
              textAlign: TextAlign.end,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(int totalCompleted, double acceptanceRate) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.primaryGreen,
            value: '100%',
            label: 'Penyelesaian',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            icon: Icons.thumb_up_alt_outlined,
            color: Colors.blueAccent,
            value: '${acceptanceRate.toInt()}%',
            label: 'Penerimaan',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            icon: Icons.speed_rounded,
            color: AppColors.accentOrange,
            value: '< 5 Mnt',
            label: 'Respon Cepat',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.overline.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(BuildContext context, List<dynamic> ratings) {
    if (ratings.isNotEmpty) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ratings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final review = ratings[index];
          final stars = (review.score as num).toInt().clamp(1, 5);

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (review.reviewerName as String).isNotEmpty
                              ? review.reviewerName as String
                              : 'Mahasiswa UB',
                          style: AppTypography.body2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Mahasiswa Universitas Brawijaya',
                          style: AppTypography.caption.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(
                        stars,
                        (i) => const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review.reviewText as String,
                  style: AppTypography.body2.copyWith(
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                  style: AppTypography.overline.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    if (SupabaseService.instance.isInitialized) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 44,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              'Belum Ada Ulasan',
              style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ulasan dan penilaian dari mahasiswa akan muncul di sini setelah pesanan selesai.',
              style: AppTypography.caption.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final initialReviews = [
      {
        'name': 'Bima Aditya',
        'faculty': 'Fakultas Ekonomi dan Bisnis UB',
        'rating': 5,
        'date': '2 hari lalu',
        'comment':
            'Sangat membantu dan tepat waktu! Barang pindahan kos diangkat dengan rapi dan aman sampai kos baru di Soekarno Hatta.',
      },
      {
        'name': 'Citra Kirana',
        'faculty': 'Fakultas Ilmu Administrasi UB',
        'rating': 5,
        'date': '4 hari lalu',
        'comment':
            'Kamar kos langsung bersih dan wangi setelah dibantu bersihkan. Komunikatif sekali lewat chat.',
      },
      {
        'name': 'Dhimas Arya',
        'faculty': 'Fakultas Teknik UB',
        'rating': 5,
        'date': '1 minggu lalu',
        'comment':
            'Tebengan ke stasiun lancar banget, helm bersih dan bawa motornya hati-hati.',
      },
      {
        'name': 'Nabila Zahra',
        'faculty': 'Fakultas Kedokteran UB',
        'rating': 4,
        'date': '2 minggu lalu',
        'comment':
            'Ramah dan solutif. Bantu angkat kardus buku yang cukup berat di lantai 2.',
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: initialReviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final review = initialReviews[index];
        final stars = review['rating'] as int;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['name'] as String,
                        style: AppTypography.body2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        review['faculty'] as String,
                        style: AppTypography.caption.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: List.generate(
                      stars,
                      (i) => const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                review['comment'] as String,
                style: AppTypography.body2.copyWith(
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                review['date'] as String,
                style: AppTypography.overline.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
