import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/data/repositories/chat_repository_impl.dart';
import 'package:ubantu/main.dart';
import 'package:ubantu/ui/auth/login_view.dart';
import 'package:ubantu/ui/home/main_navigation_view.dart';

void main() {
  group('AppAuthNotifier AuthState Stream Binding Tests', () {
    late StreamController<AuthState> authController;

    setUp(() {
      authController = StreamController<AuthState>.broadcast();
      AppAuthNotifier.instance.setLoggedIn(false);
      AppAuthNotifier.instance.setOAuthCallbackPending(false);
      AppAuthNotifier.instance.cancelAuthStateListener();
    });

    tearDown(() async {
      AppAuthNotifier.instance.cancelAuthStateListener();
      AppAuthNotifier.instance.setLoggedIn(false);
      AppAuthNotifier.instance.setOAuthCallbackPending(false);
      await authController.close();
    });

    test('bindAuthStateListener updates isLoggedIn on signedIn and signedOut', () async {
      AppAuthNotifier.instance.bindAuthStateListener(authStream: authController.stream);
      expect(AppAuthNotifier.instance.isLoggedIn, isFalse);

      final fakeSession = Session.fromJson(<String, dynamic>{
        'access_token': 'fake_token',
        'token_type': 'bearer',
        'user': <String, dynamic>{
          'id': 'usr-123',
          'aud': 'authenticated',
          'role': 'authenticated',
          'email': 'student@ub.ac.id',
          'app_metadata': <String, dynamic>{},
          'user_metadata': <String, dynamic>{},
          'created_at': '2026-01-01T00:00:00.000Z',
        },
      });

      authController.add(AuthState(AuthChangeEvent.signedIn, fakeSession));
      await Future<void>.delayed(Duration.zero);

      expect(AppAuthNotifier.instance.isLoggedIn, isTrue);
      expect(AppAuthNotifier.instance.isOAuthCallbackPending, isFalse);

      authController.add(const AuthState(AuthChangeEvent.signedOut, null));
      await Future<void>.delayed(Duration.zero);

      expect(AppAuthNotifier.instance.isLoggedIn, isFalse);
    });
  });

  group('OAuth PKCE Router & Loading View Tests', () {
    late StreamController<AuthState> authController;

    setUp(() {
      authController = StreamController<AuthState>.broadcast();
      AppAuthNotifier.instance.setLoggedIn(false);
      AppAuthNotifier.instance.setOAuthCallbackPending(false);
      AppAuthNotifier.instance.bindAuthStateListener(authStream: authController.stream);
      AppRouter.router.go(AppRouter.onboarding);
    });

    tearDown(() async {
      AppAuthNotifier.instance.cancelAuthStateListener();
      AppAuthNotifier.instance.setLoggedIn(false);
      AppAuthNotifier.instance.setOAuthCallbackPending(false);
      await authController.close();
    });

    test('hasOAuthCallbackParams detects code and tokens correctly', () {
      expect(AppRouter.hasOAuthCallbackParams(Uri.parse('https://example.com/login-callback?code=pkce_abc')), isTrue);
      expect(AppRouter.hasOAuthCallbackParams(Uri.parse('https://example.com/login-callback#access_token=token_xyz')), isTrue);
      expect(AppRouter.hasOAuthCallbackParams(Uri.parse('https://example.com/login-callback?access_token=token_xyz')), isTrue);
      expect(AppRouter.hasOAuthCallbackParams(Uri.parse('https://example.com/login-callback')), isFalse);

      AppAuthNotifier.instance.setOAuthCallbackPending(true);
      expect(AppRouter.hasOAuthCallbackParams(Uri.parse('https://example.com/login-callback')), isTrue);
      AppAuthNotifier.instance.setOAuthCallbackPending(false);
    });

    testWidgets('OAuth callback with code stays on OAuthCallbackLoadingView and redirects to MainNavigationView upon signedIn', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('ListTile background color')) return;
        originalOnError?.call(details);
      };

      await tester.pumpWidget(const UbantuApp());
      await tester.pumpAndSettle();

      AppRouter.router.go('${AppRouter.loginCallback}?code=pkce_123');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(OAuthCallbackLoadingView), findsOneWidget);
      expect(find.byType(LoginView), findsNothing);

      final fakeSession = Session.fromJson(<String, dynamic>{
        'access_token': 'fake_token',
        'token_type': 'bearer',
        'user': <String, dynamic>{
          'id': 'usr-123',
          'aud': 'authenticated',
          'role': 'authenticated',
          'email': 'student@ub.ac.id',
          'app_metadata': <String, dynamic>{},
          'user_metadata': <String, dynamic>{},
          'created_at': '2026-01-01T00:00:00.000Z',
        },
      });

      authController.add(AuthState(AuthChangeEvent.signedIn, fakeSession));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(MainNavigationView), findsOneWidget);
      expect(find.byType(OAuthCallbackLoadingView), findsNothing);

      FlutterError.onError = originalOnError;
    });

    testWidgets('OAuth callback with error redirects to LoginView immediately', (tester) async {
      await tester.pumpWidget(const UbantuApp());
      await tester.pumpAndSettle();

      AppRouter.router.go('${AppRouter.loginCallback}?error=access_denied&code=pkce_123');
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOneWidget);
      expect(find.byType(OAuthCallbackLoadingView), findsNothing);
    });

    testWidgets('OAuthCallbackLoadingView times out and routes to login if session exchange fails', (tester) async {
      final testRouter = GoRouter(
        initialLocation: AppRouter.loginCallback,
        routes: [
          GoRoute(
            path: AppRouter.loginCallback,
            builder: (context, state) => const OAuthCallbackLoadingView(
              timeoutDuration: Duration(milliseconds: 50),
            ),
          ),
          GoRoute(
            path: AppRouter.login,
            builder: (context, state) => const Scaffold(body: Text('LoginScreen')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: testRouter,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('LoginScreen'), findsOneWidget);
    });
  });

  group('ChatRepositoryImpl Bounded Inbox Query Tests', () {
    test('inboxMessageColumns contains only the required summary fields', () {
      expect(
        ChatRepositoryImpl.inboxMessageColumns,
        'room_id, sender_id, message, is_read, created_at',
      );
    });

    test('computeInboxMessagesLimit bounds query message count proportional to rooms', () {
      expect(ChatRepositoryImpl.maxMessagesPerRoomInInbox, 20);
      expect(ChatRepositoryImpl.computeInboxMessagesLimit(0), 20);
      expect(ChatRepositoryImpl.computeInboxMessagesLimit(-5), 20);
      expect(ChatRepositoryImpl.computeInboxMessagesLimit(1), 20);
      expect(ChatRepositoryImpl.computeInboxMessagesLimit(5), 100);
      expect(ChatRepositoryImpl.computeInboxMessagesLimit(10), 200);
    });
  });
}
