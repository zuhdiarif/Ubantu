import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/rating_model.dart';

abstract class IRatingRepository {
  Future<AppResult<List<RatingModel>>> getRatings(String targetUserId);
  Future<AppResult<RatingModel>> addRating(String targetUserId, double score, String reviewText);
}
