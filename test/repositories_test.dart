import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/config/app_config.dart';
import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/data/repositories/sos_repository_impl.dart';
import 'package:ubantu/data/repositories/task_repository_impl.dart';
import 'package:ubantu/domain/models/app_enums.dart';

void main() {
  group('Clean MVVM Repository Implementation Unit Tests', () {
    test('AuthRepositoryImpl login & logout state', () async {
      final repo = AuthRepositoryImpl();
      expect(repo.getCurrentUser(), isNull);

      final result = await repo.login('farel@ub.ac.id', 'password123');
      expect(result.isSuccess, true);
      expect(repo.getCurrentUser()?.email, 'farel@ub.ac.id');

      await repo.logout();
      expect(repo.getCurrentUser(), isNull);
    });

    test('AuthRepositoryImpl signUp creates user', () async {
      final repo = AuthRepositoryImpl();
      final result = await repo.signUp('new@gmail.com', 'pass123', {
        'full_name': 'New User',
        'phone_number': '081234567890',
      });

      expect(result.isSuccess, true);
      expect(result.data?.email, 'new@gmail.com');
      expect(repo.didSignUpReturnSession(), false);
    });

    test('TaskRepositoryImpl getTasks list fetching', () async {
      final repo = TaskRepositoryImpl();
      final result = await repo.getTasks();

      expect(result.isSuccess, true);
      expect(result.data?.isNotEmpty, true);
    });

    test('SosRepositoryImpl submit & status mutation', () async {
      final repo = SosRepositoryImpl();
      final result = await repo.submitSosReport('Kondisi darurat');

      expect(result.isSuccess, true);
      expect(result.data?.issueType, 'Kondisi darurat');

      await repo.updateSosStatus(SosStatus.handling);
    });

    test('AppConfig isUbEmail detection', () {
      expect(AppConfig.isUbEmail('farel@student.ub.ac.id'), true);
      expect(AppConfig.isUbEmail('FAREL@STUDENT.UB.AC.ID'), true);
      expect(AppConfig.isUbEmail('test@gmail.com'), false);
      expect(AppConfig.isUbEmail('user@yahoo.com'), false);
    });
  });
}
