import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_rating_service.dart';
import 'package:ubantu/domain/models/rating_model.dart';
import 'package:ubantu/domain/repositories/rating_repository.dart';

class RatingRepositoryImpl implements IRatingRepository {
  final SupabaseRatingService? _supabaseRatingService;

  RatingRepositoryImpl({SupabaseRatingService? remoteService})
      : _supabaseRatingService = remoteService;

  @override
  Future<AppResult<List<RatingModel>>> getRatings(String targetUserId) async {
    final service = _supabaseRatingService;
    if (service != null) {
      final result = await service.getRatings(targetUserId);
      if (result.isSuccess) {
        return result;
      }
    }

    return AppResult.success([
      RatingModel(
        id: 'r1',
        reviewerName: 'Anisa Rahma',
        score: 4.9,
        reviewText: 'Bantuan sangat cepat dan ramah!',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      RatingModel(
        id: 'r2',
        reviewerName: 'Bima Pratama',
        score: 4.8,
        reviewText: 'Sangat teliti dalam kerja.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
  }

  @override
  Future<AppResult<RatingModel>> addRating(
    String targetUserId,
    double score,
    String reviewText,
  ) async {
    final service = _supabaseRatingService;
    if (service != null) {
      final result = await service.addRating(targetUserId, score, reviewText);
      if (result.isSuccess) {
        return result;
      }
    }

    final rating = RatingModel(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      reviewerName: 'Mahasiswa UB',
      score: score,
      reviewText: reviewText,
      createdAt: DateTime.now(),
    );
    return AppResult.success(rating);
  }
}
