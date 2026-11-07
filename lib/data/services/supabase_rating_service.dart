import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/models/rating_model.dart';

class SupabaseRatingService {
  final SupabaseClient? _client;

  bool get isAvailable => _client != null || SupabaseService.instance.isInitialized;

  SupabaseRatingService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  Future<AppResult<List<RatingModel>>> getRatings(String targetUserId) async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
    try {
      final response = await _effectiveClient
          .from('ratings')
          .select()
          .eq('target_user_id', targetUserId)
          .order('created_at', ascending: false);

      final ratings = (response as List<dynamic>)
          .map((json) => RatingModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return AppResult.success(ratings);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<RatingModel>> addRating(String targetUserId, double score, String reviewText) async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
    try {
      final user = _effectiveClient.auth.currentUser;
      final payload = {
        'target_user_id': targetUserId,
        'reviewer_id': user?.id,
        'reviewer_name': user?.userMetadata?['full_name'] ?? 'Mahasiswa UB',
        'score': score,
        'review_text': reviewText,
      };

      final response = await _effectiveClient
          .from('ratings')
          .insert(payload)
          .select()
          .single();

      return AppResult.success(RatingModel.fromJson(response));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<Map<String, dynamic>>> fetchRatingSummary(String targetUserId) async {
    final ratingsResult = await getRatings(targetUserId);
    if (!ratingsResult.isSuccess) {
      return AppResult.failure(ratingsResult.errorMessage ?? 'Failed to fetch rating summary');
    }
    final list = ratingsResult.data ?? [];
    final count = list.length;
    final avg = count > 0
        ? list.map((e) => e.score).reduce((a, b) => a + b) / count
        : 5.0;
    return AppResult.success({
      'average': double.parse(avg.toStringAsFixed(1)),
      'count': count,
    });
  }
}
