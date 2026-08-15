import 'package:ubantu/domain/models/task_filter_model.dart';
import 'package:ubantu/domain/models/task_model.dart';

class SearchTasksUseCase {
  List<TaskModel> execute(List<TaskModel> tasks, TaskFilterModel filter) {
    return tasks.where((task) {
      if (filter.category != null && task.category != filter.category) {
        return false;
      }
      if (filter.status != null && task.status != filter.status) {
        return false;
      }
      if (filter.minRating != null && task.rating < filter.minRating!) {
        return false;
      }
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        final matchTitle = task.title.toLowerCase().contains(query);
        final matchRequester = task.requesterName.toLowerCase().contains(query);
        final matchLocation = task.location.toLowerCase().contains(query);
        if (!matchTitle && !matchRequester && !matchLocation) {
          return false;
        }
      }
      if (filter.locationQuery != null && filter.locationQuery!.isNotEmpty) {
        if (!task.location.toLowerCase().contains(filter.locationQuery!.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
