import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_rating_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/rating_model.dart';
import 'package:ubantu/domain/repositories/rating_repository.dart';
import 'package:ubantu/domain/repositories/session_scoped.dart';

class RatingRepositoryImpl implements IRatingRepository, SessionScoped {
  final SupabaseRatingService _remoteService;

  RatingRepositoryImpl({
    SupabaseRatingService? remoteService,
    SupabaseRatingService? service,
  }) : _remoteService = remoteService ?? service ?? SupabaseRatingService();

  @override
  void clearSessionCache() {}

  bool get hasRemoteService => true;
  SupabaseRatingService get remoteService => _remoteService;
  bool get isRemoteActive => SupabaseService.instance.isInitialized;
  bool get _useSupabase => isRemoteActive;

  @override
  Future<AppResult<List<RatingModel>>> getRatings(String targetUserId) async {
    if (_useSupabase) {
      final result = await _remoteService.getRatings(targetUserId);
      if (result.isSuccess) {
        return result;
      }
      return AppResult.success([]);
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
    if (_useSupabase) {
      final result = await _remoteService.addRating(targetUserId, score, reviewText);
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
