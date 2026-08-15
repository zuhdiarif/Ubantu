import 'package:flutter/material.dart';
import 'package:ubantu/data/repositories/notification_repository_impl.dart';
import 'package:ubantu/domain/models/notification_model.dart';
import 'package:ubantu/domain/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final INotificationRepository _repository;

  NotificationProvider({INotificationRepository? repository})
      : _repository = repository ?? NotificationRepositoryImpl();

  List<NotificationModel> get notifications => _repository.getNotifications();
  int get unreadCount => _repository.getUnreadCount();

  void addNotification(String title, String message) {
    _repository.addNotification(title, message);
    notifyListeners();
  }

  void markAllAsRead() {
    _repository.markAllAsRead();
    notifyListeners();
  }
}
