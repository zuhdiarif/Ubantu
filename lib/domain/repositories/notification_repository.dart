import 'package:ubantu/domain/models/notification_model.dart';

abstract class INotificationRepository {
  List<NotificationModel> getNotifications();
  int getUnreadCount();
  void addNotification(String title, String message);
  void markAllAsRead();
}
