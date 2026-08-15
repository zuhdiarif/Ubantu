import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/task_model.dart';

class SupabaseTaskService {
  final SupabaseClient? _client;

  SupabaseTaskService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  Future<AppResult<List<TaskModel>>> getTasks() async {
    try {
      final response = await _effectiveClient
          .from('tasks')
          .select()
          .order('created_at', ascending: false);

      final tasks = (response as List<dynamic>)
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return AppResult.success(tasks);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<TaskModel>> createTask(TaskModel task) async {
    try {
      final data = task.toJson()..remove('id');
      final response = await _effectiveClient
          .from('tasks')
          .insert(data)
          .select()
          .single();

      return AppResult.success(TaskModel.fromJson(response));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }
}
