import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/sos_provider.dart';
import 'package:ubantu/presentation/providers/task_provider.dart';

void main() {
  group('Clean MVVM Providers Unit Tests', () {
    test('AuthProvider login and logout', () async {
      final authProvider = AuthProvider();
      expect(authProvider.currentUser, isNull);

      await authProvider.login('test@ub.ac.id', 'password123');
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser?.email, 'test@ub.ac.id');

      await authProvider.logout();
      expect(authProvider.currentUser, isNull);
    });

    test('AuthProvider signInWithGoogle state', () async {
      final authProvider = AuthProvider();
      final success = await authProvider.signInWithGoogle();
      expect(success, true);
      expect(authProvider.currentUser?.email, 'user@google.com');
      expect(authProvider.isAuthenticated, true);
    });

    test('TaskProvider load tasks and mode switch', () async {
      final taskProvider = TaskProvider();
      expect(taskProvider.selectedModeIndex, 0);

      taskProvider.switchMode(1);
      expect(taskProvider.selectedModeIndex, 1);

      await taskProvider.loadTasks();
      expect(taskProvider.tasks.isNotEmpty, true);
    });

    test('SosProvider reason selection & status update', () async {
      final sosProvider = SosProvider();
      expect(sosProvider.selectedReasonIndex, 0);
      expect(sosProvider.currentStatus, SosStatus.received);

      sosProvider.selectReason(2);
      expect(sosProvider.selectedReasonIndex, 2);

      await sosProvider.updateStatus(SosStatus.handling);
      expect(sosProvider.currentStatus, SosStatus.handling);
    });
  });
}
