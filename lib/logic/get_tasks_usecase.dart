import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/task_model.dart';
import 'package:ubantu/data/repositories/task_repository.dart';

class GetTasksUseCase {
  final ITaskRepository repository;

  GetTasksUseCase(this.repository);

  Future<AppResult<List<TaskModel>>> execute() {
    return repository.getTasks();
  }
}
