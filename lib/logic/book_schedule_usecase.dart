import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/smart_schedule_model.dart';
import 'package:ubantu/data/repositories/schedule_repository.dart';

class BookScheduleUseCase {
  final IScheduleRepository repository;

  BookScheduleUseCase(this.repository);

  Future<AppResult<SmartScheduleModel>> execute(SmartScheduleModel schedule) {
    return repository.bookSchedule(schedule);
  }
}
