import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/sos_report_model.dart';
import 'package:ubantu/domain/models/task_model.dart';
import 'package:ubantu/domain/models/user_model.dart';

void main() {
  group('Domain Model Tests', () {
    test('UserModel fromJson & toJson serialization', () {
      final json = {
        'id': 'usr_1',
        'full_name': 'Farel Brawijaya',
        'email': 'farel@student.ub.ac.id',
        'phone_number': '081234567890',
        'nim': '245150200111001',
        'verification_status': 'verified',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'usr_1');
      expect(user.fullName, 'Farel Brawijaya');
      expect(user.verificationStatus, KtmVerificationStatus.verified);

      final backToJson = user.toJson();
      expect(backToJson['full_name'], 'Farel Brawijaya');
    });
  });

  group('TaskModel Tests', () {
    test('TaskModel parsing with default enum fallbacks', () {
      final json = {
        'id': 'task_1',
        'title': 'Bersih Kos',
        'requester_name': 'Nasya',
        'rating': 4.8,
        'rating_count': 23,
        'category': 'bersihKos',
        'location': 'Jl. Veteran, Malang',
        'date': '20 Juli 2026',
        'time': '09:00',
        'notes': 'Kos bersih',
      };

      final task = TaskModel.fromJson(json);
      expect(task.title, 'Bersih Kos');
      expect(task.rating, 4.8);
      expect(task.category, ServiceCategory.bersihKos);
    });
  });

  group('SosReportModel & AppResult Tests', () {
    test('SosReportModel fromJson', () {
      final json = {
        'id': 'sos_1',
        'user_id': 'usr_1',
        'issue_type': 'Merasa tidak aman',
        'status': 'received',
      };

      final sos = SosReportModel.fromJson(json);
      expect(sos.issueType, 'Merasa tidak aman');
      expect(sos.status, SosStatus.received);
    });

    test('AppResult success and failure state', () {
      final success = AppResult.success('OK');
      expect(success.isSuccess, true);
      expect(success.data, 'OK');

      final failure = AppResult<String>.failure('Error occurred');
      expect(failure.isSuccess, false);
      expect(failure.errorMessage, 'Error occurred');
    });
  });
}
