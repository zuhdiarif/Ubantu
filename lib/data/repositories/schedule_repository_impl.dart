import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_order_service.dart';
import 'package:ubantu/data/services/supabase_schedule_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/smart_schedule_model.dart';
import 'package:ubantu/domain/models/student_schedule_model.dart';
import 'package:ubantu/domain/repositories/schedule_repository.dart';
import 'package:ubantu/domain/repositories/session_scoped.dart';

class ScheduleRepositoryImpl implements IScheduleRepository, SessionScoped {
  final SupabaseScheduleService _remoteService;
  final SupabaseOrderService _orderService;

  static const List<StudentScheduleModel> _defaultStudentSchedules = [
    StudentScheduleModel(
      id: 'sched_1',
      userId: 'mock_mitra',
      dayOfWeek: 1,
      startTime: '08:00',
      endTime: '09:40',
      courseName: 'Pemrograman Mobile',
    ),
    StudentScheduleModel(
      id: 'sched_2',
      userId: 'mock_mitra',
      dayOfWeek: 3,
      startTime: '10:00',
      endTime: '11:40',
      courseName: 'Basis Data Terdistribusi',
    ),
    StudentScheduleModel(
      id: 'sched_3',
      userId: 'mock_mitra',
      dayOfWeek: 5,
      startTime: '13:00',
      endTime: '15:30',
      courseName: 'Praktikum Jaringan Komputer',
    ),
  ];

  final List<StudentScheduleModel> _mockStudentSchedules = List.from(_defaultStudentSchedules);

  ScheduleRepositoryImpl({
    SupabaseScheduleService? remoteService,
    SupabaseScheduleService? service,
    SupabaseOrderService? orderService,
  })  : _remoteService = remoteService ?? service ?? SupabaseScheduleService(),
        _orderService = orderService ?? SupabaseOrderService();

  bool get hasRemoteService => true;
  SupabaseScheduleService get remoteService => _remoteService;
  SupabaseOrderService get orderService => _orderService;
  bool get isRemoteActive => SupabaseService.instance.isInitialized;
  bool get _useSupabase => isRemoteActive;

  @override
  Future<AppResult<List<SmartScheduleModel>>> getSchedules(String userId) async {
    if (_useSupabase) {
      final result = await _remoteService.getSchedules(userId);
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
    if (_useSupabase) {
      final result = await _remoteService.bookSchedule(schedule);
      if (result.isSuccess) {
        return result;
      }
    }

    return AppResult.success(schedule);
  }

  @override
  Future<AppResult<List<StudentScheduleModel>>> getStudentSchedules(String userId) async {
    if (_useSupabase) {
      final result = await _remoteService.getStudentSchedules(userId);
      if (result.isSuccess) {
        return result;
      }
    }

    return AppResult.success(List.from(_mockStudentSchedules));
  }

  @override
  Future<AppResult<StudentScheduleModel>> addStudentSchedule(StudentScheduleModel schedule) async {
    if (_useSupabase) {
      final result = await _remoteService.addStudentSchedule(schedule);
      if (result.isSuccess) {
        return result;
      }
    }

    _mockStudentSchedules.add(schedule);
    return AppResult.success(schedule);
  }

  @override
  Future<AppResult<bool>> deleteStudentSchedule(String scheduleId) async {
    if (_useSupabase) {
      final result = await _remoteService.deleteStudentSchedule(scheduleId);
      if (result.isSuccess) {
        return result;
      }
    }

    _mockStudentSchedules.removeWhere((s) => s.id == scheduleId);
    return AppResult.success(true);
  }

  @override
  void clearSessionCache() {
    _mockStudentSchedules.clear();
    _mockStudentSchedules.addAll(_defaultStudentSchedules);
  }
}
