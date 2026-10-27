import 'package:flutter/material.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/data/repositories/notification_repository_impl.dart';
import 'package:ubantu/domain/models/notification_model.dart';
import 'package:ubantu/domain/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final INotificationRepository _repository;
  String _selectedFilter = 'Semua';

  NotificationProvider({INotificationRepository? repository})
      : _repository = repository ?? ServiceLocator.instance.notificationRepository {
    final repo = _repository;
    if (repo is NotificationRepositoryImpl) {
      repo.service.addListener(_onServiceChanged);
    }
  }

  void _onServiceChanged() {
    notifyListeners();
  }

  String get selectedFilter => _selectedFilter;

  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  List<NotificationModel> get notifications => _repository.getNotifications();

  List<NotificationModel> get filteredNotifications {
    final all = _repository.getNotifications();
    if (_selectedFilter == 'Pesanan') {
      return all.where((n) => n.type == 'order').toList();
    }
    if (_selectedFilter == 'KTM') {
      return all.where((n) => n.type == 'ktm').toList();
    }
    if (_selectedFilter == 'Pesan') {
      return all.where((n) => n.type == 'chat').toList();
    }
    return all;
  }

  int get unreadCount => _repository.getUnreadCount();

  void addNotification(String title, String message, {String type = 'general'}) {
    _repository.addNotification(title, message, type: type);
    notifyListeners();
  }

  void markAllAsRead() {
    _repository.markAllAsRead();
    notifyListeners();
  }

  void markAsRead(String id) {
    final repo = _repository;
    if (repo is NotificationRepositoryImpl) {
      repo.service.markAsRead(id);
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    final repo = _repository;
    if (repo is NotificationRepositoryImpl) {
      repo.service.deleteNotification(id);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    final repo = _repository;
    if (repo is NotificationRepositoryImpl) {
      repo.service.removeListener(_onServiceChanged);
    }
    super.dispose();
  }
}
