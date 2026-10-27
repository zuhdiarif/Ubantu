import 'package:ubantu/domain/models/task_filter_model.dart';
import 'package:ubantu/domain/models/task_model.dart';

class FilterTasksUseCase {
  List<TaskModel> execute(List<TaskModel> tasks, TaskFilterModel filter) {
    return tasks.where((task) {
      if (filter.isFemaleOnly != null && filter.isFemaleOnly! && !task.isFemaleOnly) {
        return false;
      }
      if (filter.category != null && task.category != filter.category) {
        return false;
      }
      if (filter.minRating != null && task.rating < filter.minRating!) {
        return false;
      }
      if (filter.locationQuery != null && filter.locationQuery!.isNotEmpty) {
        final query = filter.locationQuery!.toLowerCase();
        final matchesLoc = task.location.toLowerCase().contains(query);
        final matchesTitle = task.title.toLowerCase().contains(query);
        if (!matchesLoc && !matchesTitle) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
