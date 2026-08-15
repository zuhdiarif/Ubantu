import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/mock_task_service.dart';
import 'package:ubantu/domain/models/task_model.dart';
import 'package:ubantu/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final MockTaskService _taskService;

  TaskRepositoryImpl({MockTaskService? taskService})
      : _taskService = taskService ?? MockTaskService();

  @override
  Future<AppResult<List<TaskModel>>> getTasks() {
    return _taskService.getTasks();
  }
}
