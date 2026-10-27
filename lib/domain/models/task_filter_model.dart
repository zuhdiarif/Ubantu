import 'package:ubantu/domain/models/app_enums.dart';

class TaskFilterModel {
  final ServiceCategory? category;
  final String? searchQuery;
  final String? locationQuery;
  final double? minRating;
  final TaskStatus? status;
  final bool? isFemaleOnly;

  const TaskFilterModel({
    this.category,
    this.searchQuery,
    this.locationQuery,
    this.minRating,
    this.status,
    this.isFemaleOnly,
  });

  TaskFilterModel copyWith({
    ServiceCategory? category,
    String? searchQuery,
    String? locationQuery,
    double? minRating,
    TaskStatus? status,
    bool? isFemaleOnly,
  }) {
    return TaskFilterModel(
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      locationQuery: locationQuery ?? this.locationQuery,
      minRating: minRating ?? this.minRating,
      status: status ?? this.status,
      isFemaleOnly: isFemaleOnly ?? this.isFemaleOnly,
    );
  }
}
