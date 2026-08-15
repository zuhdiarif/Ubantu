class RatingModel {
  final String id;
  final String reviewerName;
  final double score;
  final String reviewText;
  final DateTime createdAt;

  const RatingModel({
    required this.id,
    required this.reviewerName,
    required this.score,
    required this.reviewText,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as String? ?? '',
      reviewerName: json['reviewer_name'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 5.0,
      reviewText: json['review_text'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewer_name': reviewerName,
      'score': score,
      'review_text': reviewText,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
