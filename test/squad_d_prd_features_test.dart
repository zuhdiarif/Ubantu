import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/ui/auth/auth_provider.dart';
import 'package:ubantu/ui/notification/notification_provider.dart';
import 'package:ubantu/ui/aktivitas/service_order_provider.dart';
import 'package:ubantu/ui/home/task_provider.dart';
import 'package:ubantu/ui/home/home_view.dart';

void main() {
  group('Squad D PRD Features Tests', () {
    testWidgets('PRD-3c: Lihat Promo button opens promo bottom sheet', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final authProvider = AuthProvider(repository: ServiceLocator.instance.authRepository);
      final taskProvider = TaskProvider(repository: ServiceLocator.instance.taskRepository);
      final serviceOrderProvider = ServiceOrderProvider(repository: ServiceLocator.instance.serviceOrderRepository);
      final notificationProvider = NotificationProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: taskProvider),
            ChangeNotifierProvider.value(value: serviceOrderProvider),
            ChangeNotifierProvider.value(value: notificationProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: HomeView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final promoButtonFinder = find.widgetWithText(ElevatedButton, 'Lihat Promo');
      expect(promoButtonFinder, findsOneWidget);

      await tester.tap(promoButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Promo UBantu 🎉'), findsOneWidget);
      expect(find.text('Gratis Biaya Admin!'), findsOneWidget);
      expect(find.text('Bonus Poin Pertama'), findsOneWidget);
      expect(find.text('Ajak Teman'), findsOneWidget);
      expect(find.byIcon(Icons.card_giftcard), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('PRD-3b: Membantu tab displays distance estimate on order cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final authProvider = AuthProvider(repository: ServiceLocator.instance.authRepository);
      final taskProvider = TaskProvider(repository: ServiceLocator.instance.taskRepository);
      final serviceOrderProvider = ServiceOrderProvider(repository: ServiceLocator.instance.serviceOrderRepository);
      final notificationProvider = NotificationProvider();

      await serviceOrderProvider.loadActiveOrders();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: taskProvider),
            ChangeNotifierProvider.value(value: serviceOrderProvider),
            ChangeNotifierProvider.value(value: notificationProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: HomeView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final membantuTabFinder = find.text('Membantu');
      expect(membantuTabFinder, findsOneWidget);

      await tester.tap(membantuTabFinder);
      await tester.pumpAndSettle();

      expect(find.textContaining('~'), findsWidgets);
      expect(find.textContaining('km'), findsWidgets);
      expect(find.byIcon(Icons.location_on), findsWidgets);
    });
  });
}
