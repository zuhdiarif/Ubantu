import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/utils/app_validators.dart';
import 'package:ubantu/data/services/notification_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/barter_item_model.dart';
import 'package:ubantu/presentation/providers/registration_provider.dart';

void main() {
  group('AppValidators Tests', () {
    test('Email validator test', () {
      expect(AppValidators.validateEmail('invalid-email'), isNotNull);
      expect(AppValidators.validateEmail('student@ub.ac.id'), isNull);
    });

    test('Password validator test', () {
      expect(AppValidators.validatePassword('short'), isNotNull);
      expect(AppValidators.validatePassword('password123'), isNull);
    });

    test('NIM & Phone validator test', () {
      expect(AppValidators.validateNim('123'), isNotNull);
      expect(AppValidators.validateNim('245150200111001'), isNull);
      expect(AppValidators.validatePhone('07123'), isNotNull);
      expect(AppValidators.validatePhone('081234567890'), isNull);
    });
  });

  group('NotificationService Tests', () {
    test('Notification addition & read state', () {
      final notifService = NotificationService();
      expect(notifService.unreadCount, 0);

      notifService.addNotification('Laporan SOS', 'Tim kami sedang memproses.');
      expect(notifService.unreadCount, 1);

      notifService.markAllAsRead();
      expect(notifService.unreadCount, 0);
    });
  });

  group('BarterItemModel & RegistrationProvider Tests', () {
    test('BarterItemModel serialization', () {
      final json = {
        'id': 'b1',
        'title': 'Makanan',
        'description': 'Tukar dengan makanan',
        'type': 'makanan',
        'icon_asset': 'fastfood_rounded',
      };
      final item = BarterItemModel.fromJson(json);
      expect(item.type, BarterType.makanan);
    });

    test('RegistrationProvider state mutation', () {
      final regProvider = RegistrationProvider();
      expect(regProvider.ktmStatus, KtmVerificationStatus.unverified);

      regProvider.setKtmData(nim: '245150200111001');
      expect(regProvider.ktmStatus, KtmVerificationStatus.pending);

      regProvider.updateKtmStatus(KtmVerificationStatus.verified);
      expect(regProvider.ktmStatus, KtmVerificationStatus.verified);
    });
  });
}
