import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_rating_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/models/rating_model.dart';
import 'package:ubantu/data/repositories/rating_repository.dart';
import 'package:ubantu/data/repositories/session_scoped.dart';

class RatingRepositoryImpl implements IRatingRepository, SessionScoped {
  final SupabaseRatingService _remoteService;
  final Map<String, List<RatingModel>> _cachedRatings = {};

  RatingRepositoryImpl({
    SupabaseRatingService? remoteService,
    SupabaseRatingService? service,
  }) : _remoteService = remoteService ?? service ?? SupabaseRatingService();

  @override
  void clearSessionCache() {
    _cachedRatings.clear();
  }

  bool get hasRemoteService => true;
  SupabaseRatingService get remoteService => _remoteService;
  bool get isRemoteActive => SupabaseService.instance.isInitialized;
  bool get _useSupabase => isRemoteActive;

  @override
  Future<AppResult<List<RatingModel>>> getRatings(String targetUserId) async {
    if (_useSupabase) {
      final result = await _remoteService.getRatings(targetUserId);
      if (result.isSuccess && result.data != null) {
        _cachedRatings[targetUserId] = List.from(result.data!);
      }
      return result;
    }

    if (_cachedRatings.containsKey(targetUserId)) {
      return AppResult.success(List.unmodifiable(_cachedRatings[targetUserId]!));
    }

    final defaultList = [
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
    ];
    _cachedRatings[targetUserId] = List.from(defaultList);
    return AppResult.success(defaultList);
  }

  @override
  Future<AppResult<RatingModel>> addRating(
    String targetUserId,
    double score,
    String reviewText,
  ) async {
    if (_useSupabase) {
      final result =
          await _remoteService.addRating(targetUserId, score, reviewText);
      if (result.isSuccess && result.data != null) {
        _cachedRatings.putIfAbsent(targetUserId, () => []).insert(0, result.data!);
      }
      return result;
    }

    final rating = RatingModel(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      reviewerName: 'Mahasiswa UB',
      score: score,
      reviewText: reviewText,
      createdAt: DateTime.now(),
    );
    _cachedRatings.putIfAbsent(targetUserId, () => []).insert(0, rating);
    return AppResult.success(rating);
  }

  Future<AppResult<Map<String, dynamic>>> getRatingSummary(
      String targetUserId) async {
    if (_useSupabase) {
      return await _remoteService.fetchRatingSummary(targetUserId);
    }
    final ratings = await getRatings(targetUserId);
    final list = ratings.data ?? [];
    final count = list.length;
    final avg = count > 0
        ? list.map((e) => e.score).reduce((a, b) => a + b) / count
        : 5.0;
    return AppResult.success({
      'average': double.parse(avg.toStringAsFixed(1)),
      'count': count,
    });
  }

  Future<AppResult<RatingModel>> submitRating(
    String targetUserId,
    double score,
    String reviewText,
  ) =>
      addRating(targetUserId, score, reviewText);
}
