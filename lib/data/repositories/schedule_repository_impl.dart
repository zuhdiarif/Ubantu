import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_schedule_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/smart_schedule_model.dart';
import 'package:ubantu/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements IScheduleRepository {
  final SupabaseScheduleService? _supabaseScheduleService;

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
}
