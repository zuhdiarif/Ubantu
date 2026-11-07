import 'package:ubantu/ui/widgets/custom_badge.dart';
import 'package:ubantu/data/models/service_order_model.dart';
import 'package:ubantu/data/models/student_schedule_model.dart';

enum ScheduleConflictStatus {
  safe,
  near,
  conflict,
}

class ScheduleConflictResult {
  final ScheduleConflictStatus status;
  final String label;
  final BadgeType badgeType;
  final StudentScheduleModel? conflictingSchedule;

  const ScheduleConflictResult({
    required this.status,
    required this.label,
    required this.badgeType,
    this.conflictingSchedule,
  });

  static const ScheduleConflictResult safe = ScheduleConflictResult(
    status: ScheduleConflictStatus.safe,
    label: 'Aman dari Jam Kuliah',
    badgeType: BadgeType.success,
  );

  static ScheduleConflictResult near([StudentScheduleModel? schedule]) => ScheduleConflictResult(
    status: ScheduleConflictStatus.near,
    label: 'Dekat Jam Kuliah',
    badgeType: BadgeType.warning,
    conflictingSchedule: schedule,
  );

  static ScheduleConflictResult conflict([StudentScheduleModel? schedule]) => ScheduleConflictResult(
    status: ScheduleConflictStatus.conflict,
    label: 'Bentrok Jam Kuliah',
    badgeType: BadgeType.danger,
    conflictingSchedule: schedule,
  );
}

class CheckScheduleConflictUseCase {
  const CheckScheduleConflictUseCase();

  ScheduleConflictResult execute({
    required DateTime orderTime,
    required List<StudentScheduleModel> schedules,
  }) {
    final dayOfWeek = orderTime.weekday;
    final sameDaySchedules = schedules.where((s) => s.dayOfWeek == dayOfWeek).toList();

    if (sameDaySchedules.isEmpty) {
      return ScheduleConflictResult.safe;
    }

    final orderMinutes = orderTime.hour * 60 + orderTime.minute;

    for (final slot in sameDaySchedules) {
      if (orderMinutes >= slot.startMinutes && orderMinutes < slot.endMinutes) {
        return ScheduleConflictResult.conflict(slot);
      }
    }

    for (final slot in sameDaySchedules) {
      if (slot.startMinutes > orderMinutes && slot.startMinutes - orderMinutes <= 60) {
        return ScheduleConflictResult.near(slot);
      }
      if (orderMinutes >= slot.endMinutes && orderMinutes - slot.endMinutes <= 60) {
        return ScheduleConflictResult.near(slot);
      }
    }

    return ScheduleConflictResult.safe;
  }

  ScheduleConflictResult checkOrder({
    required ServiceOrderModel order,
    required List<StudentScheduleModel> schedules,
  }) {
    DateTime effectiveTime = order.scheduledAt;
    if (effectiveTime.year < 2000) {
      effectiveTime = order.createdAt.year >= 2000 ? order.createdAt : DateTime.now();
    }
    return execute(
      orderTime: effectiveTime,
      schedules: schedules,
    );
  }
}
