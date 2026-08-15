import 'package:ubantu/domain/models/app_enums.dart';

class SmartScheduleModel {
  final String id;
  final String userId;
  final String taskId;
  final String taskTitle;
  final DateTime scheduledTime;
  final ServiceCategory category;
  final bool isReminderEnabled;
  final TaskStatus status;

  const SmartScheduleModel({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.taskTitle,
    required this.scheduledTime,
    required this.category,
    this.isReminderEnabled = true,
    this.status = TaskStatus.pending,
  });

  factory SmartScheduleModel.fromJson(Map<String, dynamic> json) {
    return SmartScheduleModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      taskId: json['task_id'] as String? ?? '',
      taskTitle: json['task_title'] as String? ?? '',
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.parse(json['scheduled_time'] as String)
          : DateTime.now(),
      category: ServiceCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ServiceCategory.bersihKos,
      ),
      isReminderEnabled: json['is_reminder_enabled'] as bool? ?? true,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'task_id': taskId,
      'task_title': taskTitle,
      'scheduled_time': scheduledTime.toIso8601String(),
      'category': category.name,
      'is_reminder_enabled': isReminderEnabled,
      'status': status.name,
    };
  }
}
