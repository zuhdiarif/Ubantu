import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/di/service_locator.dart';

void main() {
  group('Clean MVVM UseCase Unit Tests', () {
    test('LoginUseCase execution test', () async {
      final useCase = ServiceLocator.instance.loginUseCase;
      final result = await useCase.execute('student@ub.ac.id', 'password123');

      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data?.email, 'student@ub.ac.id');
    });

    test('GetTasksUseCase execution test', () async {
      final useCase = ServiceLocator.instance.getTasksUseCase;
      final result = await useCase.execute();

      expect(result.isSuccess, true);
      expect(result.data, isNotNull);
      expect(result.data!.length, 7);
    });

    test('SubmitSosUseCase execution test', () async {
      final useCase = ServiceLocator.instance.submitSosUseCase;
      final result = await useCase.execute('Merasa tidak aman');

      expect(result.isSuccess, true);
      expect(result.data?.issueType, 'Merasa tidak aman');
    });
  });
}
