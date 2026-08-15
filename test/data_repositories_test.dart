import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/data/repositories/network_repository_impl.dart';
import 'package:ubantu/data/repositories/notification_repository_impl.dart';

void main() {
  group('New Data Layer Repositories Unit Tests', () {
    test('NetworkRepositoryImpl connectivity status update', () {
      final repo = NetworkRepositoryImpl();
      expect(repo.isConnected(), true);

      repo.setConnectionStatus(false);
      expect(repo.isConnected(), false);
    });

    test('NotificationRepositoryImpl add and mark read state', () {
      final repo = NotificationRepositoryImpl();
      expect(repo.getUnreadCount(), 0);

      repo.addNotification('Judul', 'Pesan Notifikasi');
      expect(repo.getUnreadCount(), 1);

      repo.markAllAsRead();
      expect(repo.getUnreadCount(), 0);
    });
  });
}
