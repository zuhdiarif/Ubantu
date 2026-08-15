import 'package:ubantu/domain/models/app_enums.dart';

class TaskFilterModel {
  final ServiceCategory? category;
  final String? locationQuery;
  final double? minRating;

  const TaskFilterModel({
    this.category,
    this.locationQuery,
    this.minRating,
  });

  TaskFilterModel copyWith({
    ServiceCategory? category,
    String? locationQuery,
    double? minRating,
  }) {
    return TaskFilterModel(
      category: category ?? this.category,
      locationQuery: locationQuery ?? this.locationQuery,
      minRating: minRating ?? this.minRating,
    );
  }
}
