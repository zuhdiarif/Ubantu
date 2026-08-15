import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/presentation/providers/registration_provider.dart';

void main() {
  group('OTP Verification Unit Tests', () {
    test('SendOtpUseCase execution test', () async {
      final regProvider = RegistrationProvider();
      regProvider.setAccountDetails(
        fullName: 'Farel Brawijaya',
        email: 'farel@student.ub.ac.id',
        phone: '081234567890',
        password: 'password123',
      );

      final sent = await regProvider.sendOtp();
      expect(sent, true);
    });

    test('VerifyOtpUseCase 6-digit verification test', () async {
      final regProvider = RegistrationProvider();
      regProvider.setAccountDetails(
        fullName: 'Farel Brawijaya',
        email: 'farel@student.ub.ac.id',
        phone: '081234567890',
        password: 'password123',
      );

      final validSuccess = await regProvider.verifyOtp('123456');
      expect(validSuccess, true);

      final invalidSuccess = await regProvider.verifyOtp('12');
      expect(invalidSuccess, false);
      expect(regProvider.otpError, isNotNull);
    });

    test('Conditional signUp UB email goes to KTM', () async {
      final regProvider = RegistrationProvider();
      regProvider.setAccountDetails(
        fullName: 'Farel',
        email: 'farel@student.ub.ac.id',
        phone: '081234567890',
        password: 'password123',
      );

      expect(regProvider.isUbEmail, true);
      final nextStep = await regProvider.signUp();
      expect(nextStep, RegistrationNextStep.ktmVerification);
    });

    test('Conditional signUp non-UB email goes to OTP', () async {
      final regProvider = RegistrationProvider();
      regProvider.setAccountDetails(
        fullName: 'Test User',
        email: 'test@gmail.com',
        phone: '081234567890',
        password: 'password123',
      );

      expect(regProvider.isUbEmail, false);
      final nextStep = await regProvider.signUp();
      expect(nextStep, RegistrationNextStep.otpVerification);
    });
  });
}
