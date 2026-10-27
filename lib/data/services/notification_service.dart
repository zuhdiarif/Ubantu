import 'package:flutter/material.dart';
import 'package:ubantu/domain/models/notification_model.dart';


class NotificationService extends ChangeNotifier {
  final List<NotificationModel> _notifications;

  NotificationService({List<NotificationModel>? initialNotifications})
      : _notifications = initialNotifications != null
            ? List.from(initialNotifications)
            : [];

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification(
    String title,
    String message, {
    String userId = 'usr_current',
    String type = 'general',
  }) {
    final newNotif = NotificationModel(
      id: 'notif_${DateTime.now().microsecondsSinceEpoch}_${_notifications.length}',
      userId: userId,
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
    );
    _notifications.insert(0, newNotif);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clear() {
    _notifications.clear();
    notifyListeners();
  }
}
