import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/main.dart';
import 'package:ubantu/presentation/views/main_navigation_view.dart';
import 'package:ubantu/presentation/views/onboarding_view.dart';

void main() {
  setUp(() {
    AppAuthNotifier.instance.setLoggedIn(false);
    AppRouter.router.go(AppRouter.onboarding);
  });

  tearDown(() {
    AppAuthNotifier.instance.setLoggedIn(false);
  });

  testWidgets('Unauthenticated app defaults to OnboardingView', (tester) async {
    await tester.pumpWidget(const UbantuApp());
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingView), findsOneWidget);
    expect(find.byType(MainNavigationView), findsNothing);
  });

  testWidgets('Authenticated state automatically redirects to MainNavigationView', (tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('ListTile background color')) return;
      originalOnError?.call(details);
    };

    AppAuthNotifier.instance.setLoggedIn(true);
    await tester.pumpWidget(const UbantuApp());
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigationView), findsOneWidget);
    expect(find.byType(OnboardingView), findsNothing);

    FlutterError.onError = originalOnError;
  });

  testWidgets('Navigating to loginCallback route redirects to MainNavigationView', (tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('ListTile background color')) return;
      originalOnError?.call(details);
    };

    await tester.pumpWidget(const UbantuApp());
    await tester.pumpAndSettle();

    AppRouter.router.go(AppRouter.loginCallback);
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigationView), findsOneWidget);

    FlutterError.onError = originalOnError;
  });
}
