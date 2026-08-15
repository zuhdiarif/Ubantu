import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/core/utils/mock_data_factory.dart';
import 'package:ubantu/domain/models/task_model.dart';

class MockTaskService {
  Future<AppResult<List<TaskModel>>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return AppResult.success(MockDataFactory.mockTasks);
  }
}
