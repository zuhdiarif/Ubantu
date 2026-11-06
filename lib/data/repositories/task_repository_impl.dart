import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/mock_task_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/services/supabase_task_service.dart';
import 'package:ubantu/domain/models/task_model.dart';
import 'package:ubantu/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final MockTaskService _mockService;
  final SupabaseTaskService _supabaseService;

  TaskRepositoryImpl({
    MockTaskService? mockService,
    SupabaseTaskService? remoteService,
  })  : _mockService = mockService ?? MockTaskService(),
        _supabaseService = remoteService ?? SupabaseTaskService();

  bool get hasRemoteService => true;
  SupabaseTaskService get remoteService => _supabaseService;
  bool get isRemoteActive => SupabaseService.instance.isInitialized;

  @override
  Future<AppResult<List<TaskModel>>> getTasks() async {
    if (isRemoteActive) {
      final result = await _supabaseService.getTasks();
      if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
        return result;
      }
    }
    return _mockService.getTasks();
  }
}
