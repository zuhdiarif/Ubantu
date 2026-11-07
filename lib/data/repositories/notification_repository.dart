import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/notification_model.dart';

abstract class INotificationRepository {
  List<NotificationModel> getNotifications();
  int getUnreadCount();
  void addNotification(String title, String message, {String type = 'general'});
  void markAllAsRead();
  Future<AppResult<bool>> markAsRead(String id) async => AppResult.success(true);
  Future<AppResult<bool>> deleteNotification(String id) async => AppResult.success(true);
  Future<void> loadRemoteNotifications() async {}
}
