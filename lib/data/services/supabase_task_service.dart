import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/task_model.dart';

class SupabaseTaskService {
  final SupabaseClient? _client;
  final String? currentUserIdOverride;

  bool get isAvailable => _client != null || SupabaseService.instance.isInitialized;

  SupabaseTaskService({
    SupabaseClient? supabaseClient,
    this.currentUserIdOverride,
  }) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  String? get currentUserId =>
      currentUserIdOverride ??
      (_client != null
          ? _client.auth.currentUser?.id
          : (SupabaseService.instance.isInitialized
              ? SupabaseService.instance.client.auth.currentUser?.id
              : null));

  Future<AppResult<List<TaskModel>>> getTasks({String? excludeRequesterId}) async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
    try {
      final activeUserId = excludeRequesterId ?? currentUserId;
      var query = _effectiveClient
          .from('service_orders')
          .select()
          .eq('status', MoveServiceStatus.waiting.name);

      if (activeUserId != null && activeUserId.isNotEmpty) {
        query = query.neq('requester_id', activeUserId);
      }

      final response = await query.order('created_at', ascending: false);

      final rows = (response as List<dynamic>)
          .map((json) => Map<String, dynamic>.from(json as Map))
          .where((row) {
            if (activeUserId != null && activeUserId.isNotEmpty) {
              if (row['requester_id']?.toString() == activeUserId) {
                return false;
              }
            }
            return true;
          })
          .toList();

      final missingRequesterIds = rows
          .where((r) {
            final rName = r['requester_name']?.toString();
            final rId = r['requester_id']?.toString();
            return (rName == null || rName.trim().isEmpty) &&
                (rId != null && rId.trim().isNotEmpty);
          })
          .map((r) => r['requester_id'].toString())
          .toSet();

      if (missingRequesterIds.isNotEmpty) {
        try {
          final profilesRes = await _effectiveClient
              .from('profiles')
              .select('id, full_name')
              .inFilter('id', missingRequesterIds.toList());
          final Map<String, String> nameMap = {};
          for (final p in profilesRes as List<dynamic>) {
            if (p is Map && p['id'] != null && p['full_name'] != null) {
              final fullName = p['full_name'].toString().trim();
              if (fullName.isNotEmpty) {
                nameMap[p['id'].toString()] = fullName;
              }
            }
          }
          for (final row in rows) {
            final rName = row['requester_name']?.toString();
            final rId = row['requester_id']?.toString();
            if ((rName == null || rName.trim().isEmpty) &&
                rId != null &&
                nameMap.containsKey(rId)) {
              row['requester_name'] = nameMap[rId];
            }
          }
        } catch (_) {}
      }

      final tasks = rows
          .map((json) => TaskModel.fromJson(json))
          .toList();

      return AppResult.success(tasks);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<TaskModel>> createTask(TaskModel task) async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
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
      if (task.requesterName.trim().isNotEmpty) {
        payload['requester_name'] = task.requesterName.trim();
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
