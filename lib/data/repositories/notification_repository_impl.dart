import 'package:ubantu/data/services/notification_service.dart';
import 'package:ubantu/data/services/supabase_notification_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/notification_model.dart';
import 'package:ubantu/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements INotificationRepository {
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
  }

  @override
  void markAllAsRead() {
    _service.markAllAsRead();
    if (isRemoteActive) {
      _supabaseService.markAllAsRead();
    }
  }
}
