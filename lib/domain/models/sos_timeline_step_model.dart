class SosTimelineStepModel {
  final String title;
  final String description;
  final String timestamp;
  final bool isCompleted;
  final bool isActive;

  const SosTimelineStepModel({
    required this.title,
    required this.description,
    required this.timestamp,
    this.isCompleted = false,
    this.isActive = false,
  });

  factory SosTimelineStepModel.fromJson(Map<String, dynamic> json) {
    return SosTimelineStepModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp,
      'is_completed': isCompleted,
      'is_active': isActive,
    };
  }
}
