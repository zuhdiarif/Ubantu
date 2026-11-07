class StudentScheduleModel {
  final String id;
  final String userId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String? courseName;

  const StudentScheduleModel({
    required this.id,
    required this.userId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.courseName,
  });

  int get startHour => int.parse(startTime.split(':')[0]);
  int get startMinute => int.parse(startTime.split(':')[1]);
  int get endHour => int.parse(endTime.split(':')[0]);
  int get endMinute => int.parse(endTime.split(':')[1]);

  int get startMinutes => startHour * 60 + startMinute;
  int get endMinutes => endHour * 60 + endMinute;

  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return 'Senin';
    }
  }

  String get formattedTime => '$startTime - $endTime';

  bool overlapsWith(StudentScheduleModel other) {
    if (dayOfWeek != other.dayOfWeek) return false;
    return startMinutes < other.endMinutes && endMinutes > other.startMinutes;
  }

  StudentScheduleModel copyWith({
    String? id,
    String? userId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? courseName,
  }) {
    return StudentScheduleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      courseName: courseName ?? this.courseName,
    );
  }

  factory StudentScheduleModel.fromJson(Map<String, dynamic> json) {
    return StudentScheduleModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      dayOfWeek: json['day_of_week'] as int? ?? 1,
      startTime: json['start_time'] as String? ?? '08:00',
      endTime: json['end_time'] as String? ?? '10:00',
      courseName: json['course_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'course_name': courseName,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentScheduleModel &&
        other.id == id &&
        other.userId == userId &&
        other.dayOfWeek == dayOfWeek &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.courseName == courseName;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        dayOfWeek,
        startTime,
        endTime,
        courseName,
      );
}
