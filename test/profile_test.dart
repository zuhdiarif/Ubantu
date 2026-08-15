import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/presentation/providers/profile_provider.dart';

void main() {
  group('ProfileProvider Unit Tests', () {
    test('ProfileProvider initial state and task increment', () {
      final provider = ProfileProvider();
      expect(provider.profileStats.completedTasksCount, 12);
      expect(provider.profileStats.volunteerPoints, 150);

      provider.incrementCompletedTask();
      expect(provider.profileStats.completedTasksCount, 13);
      expect(provider.profileStats.volunteerPoints, 160);
    });
  });
}
