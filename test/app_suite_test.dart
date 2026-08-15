import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/errors/app_exceptions.dart';
import 'package:ubantu/core/utils/mock_data_factory.dart';
import 'package:ubantu/domain/models/rating_model.dart';
import 'package:ubantu/domain/models/sos_timeline_step_model.dart';

void main() {
  group('MockDataFactory Unit Tests', () {
    test('Mock user, tasks, barters and notifications generation', () {
      final user = MockDataFactory.mockUser;
      expect(user.fullName, 'Mahasiswa Tester UB');

      final tasks = MockDataFactory.mockTasks;
      expect(tasks.length, 7);

      final barters = MockDataFactory.mockBarters;
      expect(barters.length, 2);

      final notifs = MockDataFactory.mockNotifications;
      expect(notifs.length, 2);
    });
  });

  group('AppExceptions Unit Tests', () {
    test('NetworkException & AuthException instantiation', () {
      const netEx = NetworkException('No internet', 'NET_01');
      expect(netEx.message, 'No internet');
      expect(netEx.code, 'NET_01');

      const authEx = AuthException('Invalid credentials', code: 'AUTH_01');
      expect(authEx.toString().contains('Invalid credentials'), true);
    });
  });

  group('SosTimelineStepModel & RatingModel Tests', () {
    test('SosTimelineStepModel JSON serialization', () {
      final json = {
        'title': 'Diterima',
        'description': 'Laporan diterima',
        'timestamp': '10:05',
        'is_completed': true,
        'is_active': false,
      };
      final step = SosTimelineStepModel.fromJson(json);
      expect(step.title, 'Diterima');
      expect(step.isCompleted, true);
    });

    test('RatingModel JSON serialization', () {
      final json = {
        'id': 'r1',
        'reviewer_name': 'Anisa',
        'score': 4.9,
        'review_text': 'Sangat membantu!',
      };
      final rating = RatingModel.fromJson(json);
      expect(rating.reviewerName, 'Anisa');
      expect(rating.score, 4.9);
    });
  });
}
