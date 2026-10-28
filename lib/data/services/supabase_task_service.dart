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
      data.removeWhere((key, value) => value == null);

      try {
        final response = await _effectiveClient
            .from('tasks')
            .insert(data)
            .select()
            .single();

        return AppResult.success(TaskModel.fromJson(response));
      } catch (insertError) {
        final errorStr = insertError.toString().toLowerCase();
        if (errorStr.contains('is_female_only') || errorStr.contains('pgrst204')) {
          final fallbackData = Map<String, dynamic>.from(data)
            ..remove('is_female_only');
          final response = await _effectiveClient
              .from('tasks')
              .insert(fallbackData)
              .select()
              .single();

          return AppResult.success(TaskModel.fromJson(response));
        }
        rethrow;
      }
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }
}
