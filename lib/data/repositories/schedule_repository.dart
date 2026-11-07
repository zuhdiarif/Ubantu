import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/smart_schedule_model.dart';
import 'package:ubantu/data/models/student_schedule_model.dart';

abstract class IScheduleRepository {
  Future<AppResult<List<SmartScheduleModel>>> getSchedules(String userId);
  Future<AppResult<SmartScheduleModel>> bookSchedule(SmartScheduleModel schedule);
  Future<AppResult<List<StudentScheduleModel>>> getStudentSchedules(String userId);
  Future<AppResult<StudentScheduleModel>> addStudentSchedule(StudentScheduleModel schedule);
  Future<AppResult<bool>> deleteStudentSchedule(String scheduleId);
}
