import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/smart_schedule_model.dart';

abstract class IScheduleRepository {
  Future<AppResult<List<SmartScheduleModel>>> getSchedules(String userId);
  Future<AppResult<SmartScheduleModel>> bookSchedule(SmartScheduleModel schedule);
}
