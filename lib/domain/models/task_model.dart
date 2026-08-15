import 'package:ubantu/domain/models/app_enums.dart';

class TaskModel {
  final String id;
  final String title;
  final String requesterName;
  final double rating;
  final int ratingCount;
  final ServiceCategory category;
  final String location;
  final String date;
  final String time;
  final String notes;
  final TaskStatus status;
  final bool isFemaleOnly;
  final bool isEmergency;
  final int rewardPoints;

  const TaskModel({
    required this.id,
    required this.title,
    required this.requesterName,
    required this.rating,
    required this.ratingCount,
    required this.category,
    required this.location,
    required this.date,
    required this.time,
    required this.notes,
    this.status = TaskStatus.pending,
    this.isFemaleOnly = false,
    this.isEmergency = false,
    this.rewardPoints = 10,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      requesterName: json['requester_name'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['rating_count'] as int? ?? 0,
      category: ServiceCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ServiceCategory.bersihKos,
      ),
      location: json['location'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      isFemaleOnly: json['is_female_only'] as bool? ?? false,
      isEmergency: json['is_emergency'] as bool? ?? false,
      rewardPoints: json['reward_points'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'requester_name': requesterName,
      'rating': rating,
      'rating_count': ratingCount,
      'category': category.name,
      'location': location,
      'date': date,
      'time': time,
      'notes': notes,
      'status': status.name,
      'is_female_only': isFemaleOnly,
      'is_emergency': isEmergency,
      'reward_points': rewardPoints,
    };
  }
}
