import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/data/repositories/barter_repository_impl.dart';
import 'package:ubantu/data/repositories/loyalty_repository_impl.dart';
import 'package:ubantu/data/repositories/notification_repository_impl.dart';
import 'package:ubantu/data/repositories/profile_repository_impl.dart';
import 'package:ubantu/data/repositories/rating_repository_impl.dart';
import 'package:ubantu/data/repositories/schedule_repository_impl.dart';
import 'package:ubantu/data/repositories/service_order_repository_impl.dart';
import 'package:ubantu/data/repositories/sos_repository_impl.dart';
import 'package:ubantu/data/repositories/task_repository_impl.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/barter_provider.dart';
import 'package:ubantu/presentation/providers/loyalty_provider.dart';
import 'package:ubantu/presentation/providers/profile_provider.dart';
import 'package:ubantu/presentation/providers/rating_provider.dart';
import 'package:ubantu/presentation/providers/registration_provider.dart';
import 'package:ubantu/presentation/providers/schedule_provider.dart';
import 'package:ubantu/presentation/providers/task_provider.dart';

void main() {
  group('ServiceLocator and Repository DI Connection Tests', () {
    test('ServiceLocator provides all required repositories and services', () {
      final di = ServiceLocator.instance;

      expect(di.authRepository, isNotNull);
      expect(di.taskRepository, isNotNull);
      expect(di.sosRepository, isNotNull);
      expect(di.serviceOrderRepository, isNotNull);
      expect(di.mitraRepository, isNotNull);
      expect(di.chatRepository, isNotNull);
      expect(di.notificationRepository, isNotNull);
      expect(di.loyaltyRepository, isNotNull);
      expect(di.profileRepository, isNotNull);
      expect(di.barterRepository, isNotNull);
      expect(di.scheduleRepository, isNotNull);
      expect(di.ratingRepository, isNotNull);

      expect(di.mockTaskService, isNotNull);
      expect(di.supabaseTaskService, isNotNull);
      expect(di.supabaseOrderService, isNotNull);
      expect(di.supabaseSosService, isNotNull);
      expect(di.supabaseStorageService, isNotNull);
      expect(di.supabaseLoyaltyService, isNotNull);
      expect(di.supabaseProfileService, isNotNull);
      expect(di.supabaseBarterService, isNotNull);
      expect(di.supabaseScheduleService, isNotNull);
      expect(di.supabaseRatingService, isNotNull);
      expect(di.notificationService, isNotNull);
      expect(di.supabaseNotificationService, isNotNull);
      expect(di.textRecognitionService, isNotNull);
    });

    test('Repository default constructors auto-initialize remote services', () {
      final loyalty = LoyaltyRepositoryImpl();
      expect(loyalty.hasRemoteService, isTrue);
      expect(loyalty.remoteService, isNotNull);

      final profile = ProfileRepositoryImpl();
      expect(profile.hasRemoteService, isTrue);
      expect(profile.remoteService, isNotNull);
      expect(profile.storageService, isNotNull);

      final barter = BarterRepositoryImpl();
      expect(barter.hasRemoteService, isTrue);
      expect(barter.remoteService, isNotNull);

      final schedule = ScheduleRepositoryImpl();
      expect(schedule.hasRemoteService, isTrue);
      expect(schedule.remoteService, isNotNull);
      expect(schedule.orderService, isNotNull);

      final rating = RatingRepositoryImpl();
      expect(rating.hasRemoteService, isTrue);
      expect(rating.remoteService, isNotNull);

      final auth = AuthRepositoryImpl();
      expect(auth.hasRemoteService, isTrue);
      expect(auth.remoteService, isNotNull);

      final task = TaskRepositoryImpl();
      expect(task.hasRemoteService, isTrue);
      expect(task.remoteService, isNotNull);

      final serviceOrder = ServiceOrderRepositoryImpl();
      expect(serviceOrder.hasRemoteService, isTrue);
      expect(serviceOrder.remoteService, isNotNull);

      final sos = SosRepositoryImpl();
      expect(sos.hasRemoteService, isTrue);
      expect(sos.remoteService, isNotNull);

      final notification = NotificationRepositoryImpl();
      expect(notification.hasRemoteService, isTrue);
      expect(notification.remoteService, isNotNull);
    });

    test('Providers bind to ServiceLocator.instance repositories by default', () {
      final authProvider = AuthProvider();
      expect(authProvider.repository, same(ServiceLocator.instance.authRepository));

      final taskProvider = TaskProvider();
      expect(taskProvider.repository, same(ServiceLocator.instance.taskRepository));

      final registrationProvider = RegistrationProvider();
      expect(registrationProvider.repository, same(ServiceLocator.instance.authRepository));

      final profileProvider = ProfileProvider();
      expect(profileProvider.repository, same(ServiceLocator.instance.profileRepository));

      final barterProvider = BarterProvider();
      expect(barterProvider.repository, same(ServiceLocator.instance.barterRepository));

      final ratingProvider = RatingProvider();
      expect(ratingProvider.repository, same(ServiceLocator.instance.ratingRepository));

      final loyaltyProvider = LoyaltyProvider();
      expect(loyaltyProvider.repository, same(ServiceLocator.instance.loyaltyRepository));

      final scheduleProvider = ScheduleProvider();
      expect(scheduleProvider.repository, same(ServiceLocator.instance.scheduleRepository));
    });

    test('ServiceLocator.resetForTesting allows overriding repositories', () {
      final customAuth = AuthRepositoryImpl();
      final customLoyalty = LoyaltyRepositoryImpl();

      ServiceLocator.resetForTesting(
        authRepository: customAuth,
        loyaltyRepository: customLoyalty,
      );

      expect(ServiceLocator.instance.authRepository, same(customAuth));
      expect(ServiceLocator.instance.loyaltyRepository, same(customLoyalty));
      expect(ServiceLocator.instance.profileRepository, isNotNull);

      ServiceLocator.resetForTesting();
    });
  });
}
