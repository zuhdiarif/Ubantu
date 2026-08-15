import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/notification_model.dart';

class SupabaseNotificationService {
  final SupabaseClient? _client;

  SupabaseNotificationService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  Future<AppResult<List<NotificationModel>>> fetchNotifications() async {
    try {
      final user = _effectiveClient.auth.currentUser;
      final response = await _effectiveClient
          .from('notifications')
          .select()
          .eq('user_id', user?.id ?? '')
          .order('created_at', ascending: false);

      final items = (response as List<dynamic>)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return AppResult.success(items);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> markAllAsRead() async {
    try {
      final user = _effectiveClient.auth.currentUser;
      await _effectiveClient
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user?.id ?? '');

      return AppResult.success(true);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }
}
