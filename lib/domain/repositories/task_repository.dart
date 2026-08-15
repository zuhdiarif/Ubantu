import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/task_model.dart';

abstract class ITaskRepository {
  Future<AppResult<List<TaskModel>>> getTasks();
}
