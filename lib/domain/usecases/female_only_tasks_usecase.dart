import 'package:ubantu/domain/models/task_model.dart';

class FemaleOnlyTasksUseCase {
  List<TaskModel> execute(List<TaskModel> tasks) {
    return tasks.where((task) => task.isFemaleOnly).toList();
  }
}
