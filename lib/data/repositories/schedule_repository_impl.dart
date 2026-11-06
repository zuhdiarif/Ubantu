import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_schedule_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/smart_schedule_model.dart';
import 'package:ubantu/domain/models/student_schedule_model.dart';
import 'package:ubantu/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements IScheduleRepository {
  final SupabaseScheduleService? _supabaseScheduleService;

  final List<StudentScheduleModel> _mockStudentSchedules = [
    const StudentScheduleModel(
      id: 'sched_1',
      userId: 'mock_mitra',
      dayOfWeek: 1,
      startTime: '08:00',
      endTime: '09:40',
      courseName: 'Pemrograman Mobile',
    ),
    const StudentScheduleModel(
      id: 'sched_2',
      userId: 'mock_mitra',
      dayOfWeek: 3,
      startTime: '10:00',
      endTime: '11:40',
      courseName: 'Basis Data Terdistribusi',
    ),
    const StudentScheduleModel(
      id: 'sched_3',
      userId: 'mock_mitra',
      dayOfWeek: 5,
      startTime: '13:00',
      endTime: '15:30',
      courseName: 'Praktikum Jaringan Komputer',
    ),
  ];

  ScheduleRepositoryImpl({SupabaseScheduleService? remoteService})
      : _supabaseScheduleService = remoteService;

  @override
  Future<AppResult<List<SmartScheduleModel>>> getSchedules(String userId) async {
    final service = _supabaseScheduleService;
    if (service != null) {
      final result = await service.getSchedules(userId);
      if (result.isSuccess) {
        return result;
      }
    }

    return AppResult.success([
      SmartScheduleModel(
        id: 'sch_1',
        userId: userId,
        taskId: 't1',
        taskTitle: 'Jasa Bersih Kamar Kos',
        scheduledTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
        category: ServiceCategory.bersihKos,
        isReminderEnabled: true,
      ),
      SmartScheduleModel(
        id: 'sch_2',
        userId: userId,
        taskId: 't3',
        taskTitle: 'Antar Paket & Barang Fleksibel',
        scheduledTime: DateTime.now().add(const Duration(days: 2)),
        category: ServiceCategory.antarJemput,
        isReminderEnabled: true,
      ),
    ]);
  }

  @override
  Future<AppResult<SmartScheduleModel>> bookSchedule(SmartScheduleModel schedule) async {
    final service = _supabaseScheduleService;
    if (service != null) {
      final result = await service.bookSchedule(schedule);
      if (result.isSuccess) {
        return result;
      }
    }

    return AppResult.success(schedule);
  }

  @override
  Future<AppResult<List<StudentScheduleModel>>> getStudentSchedules(String userId) async {
    final service = _supabaseScheduleService;
    if (service != null) {
      final result = await service.getStudentSchedules(userId);
      if (result.isSuccess) {
        return result;
      }
    }

    return AppResult.success(List.from(_mockStudentSchedules));
  }

  @override
  Future<AppResult<StudentScheduleModel>> addStudentSchedule(StudentScheduleModel schedule) async {
    final service = _supabaseScheduleService;
    if (service != null) {
      final result = await service.addStudentSchedule(schedule);
      if (result.isSuccess) {
        return result;
      }
    }

    _mockStudentSchedules.add(schedule);
    return AppResult.success(schedule);
  }

  @override
  Future<AppResult<bool>> deleteStudentSchedule(String scheduleId) async {
    final service = _supabaseScheduleService;
    if (service != null) {
      final result = await service.deleteStudentSchedule(scheduleId);
      if (result.isSuccess) {
        return result;
      }
    }

    _mockStudentSchedules.removeWhere((s) => s.id == scheduleId);
    return AppResult.success(true);
  }
}
