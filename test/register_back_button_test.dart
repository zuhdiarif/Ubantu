import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/main.dart';
import 'package:ubantu/presentation/views/login_view.dart';
import 'package:ubantu/presentation/views/onboarding_view.dart';
import 'package:ubantu/presentation/views/register_view.dart';

void main() {
  setUp(() {
    AppRouter.router.go(AppRouter.onboarding);
  });

  testWidgets('Test navigating Onboarding -> Login -> Register -> Back button', (tester) async {
    await tester.pumpWidget(const UbantuApp());
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingView), findsOneWidget);

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);

    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterView), findsOneWidget);

    final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(RegisterView), findsNothing);
  });

  testWidgets('Test navigating Onboarding -> Register -> Back button', (tester) async {
    await tester.pumpWidget(const UbantuApp());
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingView), findsOneWidget);

    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterView), findsOneWidget);

    final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingView), findsOneWidget);
    expect(find.byType(RegisterView), findsNothing);
  });

  testWidgets('Test Register back button fallback when stack is root', (tester) async {
    await tester.pumpWidget(const UbantuApp());
    await tester.pumpAndSettle();

    AppRouter.router.go(AppRouter.register);
    await tester.pumpAndSettle();
    expect(find.byType(RegisterView), findsOneWidget);

    final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingView), findsOneWidget);
    expect(find.byType(RegisterView), findsNothing);
  });
}
