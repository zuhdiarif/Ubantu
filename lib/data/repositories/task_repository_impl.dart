import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/mock_task_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/services/supabase_task_service.dart';
import 'package:ubantu/domain/models/task_model.dart';
import 'package:ubantu/domain/repositories/session_scoped.dart';
import 'package:ubantu/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements ITaskRepository, SessionScoped {
  final MockTaskService _mockService;
  final SupabaseTaskService _supabaseService;
  final bool? isRemoteActiveOverride;

  TaskRepositoryImpl({
    MockTaskService? mockService,
    SupabaseTaskService? remoteService,
    this.isRemoteActiveOverride,
  })  : _mockService = mockService ?? MockTaskService(),
        _supabaseService = remoteService ?? SupabaseTaskService();

  bool get hasRemoteService => true;
  SupabaseTaskService get remoteService => _supabaseService;
  bool get isRemoteActive =>
      isRemoteActiveOverride ?? SupabaseService.instance.isInitialized;

  @override
  void clearSessionCache() {}

  @override
  Future<AppResult<List<TaskModel>>> getTasks() async {
    if (isRemoteActive) {
      return _supabaseService.getTasks();
    }
    return _mockService.getTasks();
  }
}
