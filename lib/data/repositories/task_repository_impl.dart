import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/mock_task_service.dart';
import 'package:ubantu/data/services/supabase_task_service.dart';
import 'package:ubantu/domain/models/task_model.dart';
import 'package:ubantu/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final MockTaskService _mockService;
  final SupabaseTaskService? _supabaseService;

  TaskRepositoryImpl({
    MockTaskService? mockService,
    SupabaseTaskService? remoteService,
  })  : _mockService = mockService ?? MockTaskService(),
        _supabaseService = remoteService;

  @override
  Future<AppResult<List<TaskModel>>> getTasks() async {
    final service = _supabaseService;
    if (service != null) {
      final result = await service.getTasks();
      if (result.isSuccess) {
        return result;
      }
    }
    return _mockService.getTasks();
  }
}
