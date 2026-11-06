import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/task_model.dart';

class SupabaseTaskService {
  final SupabaseClient? _client;

  SupabaseTaskService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  Future<AppResult<List<TaskModel>>> getTasks() async {
    try {
      final response = await _effectiveClient
          .from('service_orders')
          .select()
          .eq('status', MoveServiceStatus.waiting.name)
          .order('created_at', ascending: false);

      final tasks = (response as List<dynamic>)
          .map((json) => TaskModel.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();

      return AppResult.success(tasks);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<TaskModel>> createTask(TaskModel task) async {
    try {
      final currentUserId = _effectiveClient.auth.currentUser?.id;
      final payload = <String, dynamic>{
        'category': task.category.name,
        'status': MoveServiceStatus.waiting.name,
        'location_origin': task.location,
        'location_destination': task.location,
        'scheduled_at': DateTime.now().toIso8601String(),
        'item_description': task.title,
        'barter_type': BarterType.makanan.name,
        'barter_description': task.notes,
        'is_female_only': task.isFemaleOnly,
      };

      if (currentUserId != null) {
        payload['requester_id'] = currentUserId;
      }

      final response = await _effectiveClient
          .from('service_orders')
          .insert(payload)
          .select()
          .single();

      return AppResult.success(TaskModel.fromJson(Map<String, dynamic>.from(response as Map)));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }
}
