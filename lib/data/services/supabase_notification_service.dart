import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/models/notification_model.dart';

class SupabaseNotificationService {
  final SupabaseClient? _client;

  bool get isAvailable => _client != null || SupabaseService.instance.isInitialized;

  SupabaseNotificationService({SupabaseClient? supabaseClient}) : _client = supabaseClient;

  SupabaseClient get _effectiveClient => _client ?? SupabaseService.instance.client;

  Future<AppResult<List<NotificationModel>>> fetchNotifications() async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
    try {
      final user = _effectiveClient.auth.currentUser;
      final uid = user?.id;
      if (uid == null || uid.isEmpty) {
        return AppResult.success(<NotificationModel>[]);
      }

      final response = await _effectiveClient
          .from('notifications')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      final items = (response as List<dynamic>)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return AppResult.success(items);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<NotificationModel>> createNotification(
    NotificationModel notification,
  ) async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
    final uid = notification.userId.isNotEmpty
        ? notification.userId
        : _effectiveClient.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      return AppResult.success(notification);
    }
    try {
      final res = await _effectiveClient.from('notifications').insert({
        'user_id': uid,
        'title': notification.title,
        'body': notification.message,
        'type': notification.type,
        'is_read': notification.isRead,
      }).select().single();

      return AppResult.success(NotificationModel.fromJson(res));
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> markAllAsRead([String? userId]) async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
    final uid = userId ?? _effectiveClient.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      return AppResult.success(true);
    }
    try {
      await _effectiveClient
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', uid)
          .eq('is_read', false);

      return AppResult.success(true);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> markAsRead(String notificationId) async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
    try {
      await _effectiveClient
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      return AppResult.success(true);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<bool>> deleteNotification(String notificationId) async {
    if (!isAvailable) {
      return AppResult.failure('Supabase belum diinisialisasi.');
    }
    try {
      await _effectiveClient
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      return AppResult.success(true);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }
}
