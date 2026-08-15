import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/main.dart';
import 'package:ubantu/presentation/views/onboarding_view.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UbantuApp());
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingView), findsOneWidget);
  });
}
