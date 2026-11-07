import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/notification_service.dart';
import 'package:ubantu/data/services/supabase_notification_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/models/notification_model.dart';
import 'package:ubantu/data/repositories/notification_repository.dart';
import 'package:ubantu/data/repositories/session_scoped.dart';

class NotificationRepositoryImpl implements INotificationRepository, SessionScoped {
  final NotificationService _service;
  final SupabaseNotificationService _supabaseService;

  NotificationRepositoryImpl({
    NotificationService? service,
    SupabaseNotificationService? remoteService,
  })  : _service = service ?? NotificationService(),
        _supabaseService = remoteService ?? SupabaseNotificationService();

  bool get hasRemoteService => true;
  SupabaseNotificationService get remoteService => _supabaseService;
  NotificationService get service => _service;
  bool get isRemoteActive => SupabaseService.instance.isInitialized;

  @override
  List<NotificationModel> getNotifications() => _service.notifications;

  @override
  int getUnreadCount() => _service.unreadCount;

  @override
  void addNotification(String title, String message, {String type = 'general'}) {
    _service.addNotification(title, message, type: type);
    if (isRemoteActive) {
      final uid = SupabaseService.instance.client.auth.currentUser?.id ?? '';
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: uid,
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
      );
      _supabaseService.createNotification(notification);
    }
  }

  @override
  Future<void> loadRemoteNotifications() async {
    if (isRemoteActive) {
      final result = await _supabaseService.fetchNotifications();
      if (result.isSuccess && result.data != null) {
        _service.setNotifications(result.data!);
      }
    }
  }

  @override
  void markAllAsRead() {
    _service.markAllAsRead();
    if (isRemoteActive) {
      final uid = SupabaseService.instance.client.auth.currentUser?.id;
      if (uid != null && uid.isNotEmpty) {
        _supabaseService.markAllAsRead(uid);
      } else {
        _supabaseService.markAllAsRead();
      }
    }
  }

  @override
  Future<AppResult<bool>> markAsRead(String id) async {
    _service.markAsRead(id);
    if (isRemoteActive) {
      return _supabaseService.markAsRead(id);
    }
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> deleteNotification(String id) async {
    _service.deleteNotification(id);
    if (isRemoteActive) {
      return _supabaseService.deleteNotification(id);
    }
    return AppResult.success(true);
  }

  @override
  void clearSessionCache() {
    _service.clear();
  }
}
