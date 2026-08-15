import 'package:ubantu/data/services/notification_service.dart';
import 'package:ubantu/data/services/supabase_notification_service.dart';
import 'package:ubantu/domain/models/notification_model.dart';
import 'package:ubantu/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final NotificationService _service;
  final SupabaseNotificationService? _supabaseService;

  NotificationRepositoryImpl({
    NotificationService? service,
    SupabaseNotificationService? remoteService,
  })  : _service = service ?? NotificationService(),
        _supabaseService = remoteService;

  @override
  List<NotificationModel> getNotifications() => _service.notifications;

  @override
  int getUnreadCount() => _service.unreadCount;

  @override
  void addNotification(String title, String message) {
    _service.addNotification(title, message);
  }

  @override
  void markAllAsRead() {
    _service.markAllAsRead();
    _supabaseService?.markAllAsRead();
  }
}
