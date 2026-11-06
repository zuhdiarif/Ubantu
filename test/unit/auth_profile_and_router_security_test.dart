import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/data/services/supabase_auth_service.dart';
import 'package:ubantu/data/services/supabase_profile_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/user_model.dart';
import 'package:ubantu/main.dart';
import 'package:ubantu/presentation/views/login_view.dart';
import 'package:ubantu/presentation/views/main_navigation_view.dart';

void main() {
  group('SupabaseAuthService Profile Mapping & Fallback', () {
    final authService = SupabaseAuthService();

    test('buildUserModelForTesting preserves faculty and bio from profileResponse', () {
      const user = User(
        id: 'user-001',
        appMetadata: {},
        userMetadata: {
          'faculty': 'Metadata Faculty',
          'bio': 'Metadata Bio',
        },
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00.000Z',
      );

      final profileResponse = {
        'full_name': 'Ahmad Dahlan',
        'faculty': 'Fakultas Ilmu Komputer',
        'bio': 'Mahasiswa FILKOM angkatan 2023',
        'verification_status': 'verified',
        'role': 'provider',
      };

      final model = authService.buildUserModelForTesting(user, profileResponse);

      expect(model.id, 'user-001');
      expect(model.fullName, 'Ahmad Dahlan');
      expect(model.faculty, 'Fakultas Ilmu Komputer');
      expect(model.bio, 'Mahasiswa FILKOM angkatan 2023');
      expect(model.verificationStatus, KtmVerificationStatus.verified);
      expect(model.role, UserRole.provider);
    });

    test('buildUserModelForTesting falls back to userMetadata when profileResponse has null or empty faculty and bio', () {
      const user = User(
        id: 'user-002',
        appMetadata: {},
        userMetadata: {
          'full_name': 'Siti Aminah',
          'faculty': 'Fakultas Teknik',
          'bio': 'Penggiat robotika dan otomasi',
          'phone_number': '081299990000',
        },
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00.000Z',
      );

      final profileWithNullAndEmpty = {
        'full_name': null,
        'verification_status': 'verified',
        'role': 'customer',
        'faculty': null,
        'bio': '   ',
      };

      final model = authService.buildUserModelForTesting(user, profileWithNullAndEmpty);

      expect(model.id, 'user-002');
      expect(model.fullName, 'Siti Aminah');
      expect(model.faculty, 'Fakultas Teknik');
      expect(model.bio, 'Penggiat robotika dan otomasi');
      expect(model.phoneNumber, '081299990000');
      expect(model.verificationStatus, KtmVerificationStatus.verified);
      expect(model.role, UserRole.customer);
    });

    test('buildUserModelForTesting falls back completely to userMetadata when profileResponse is null', () {
      const user = User(
        id: 'user-003',
        appMetadata: {},
        userMetadata: {
          'full_name': 'Rudi Hartono',
          'faculty': 'Fakultas Kedokteran',
          'bio': 'Asisten Lab Anatomi',
          'verification_status': 'pending',
          'role': 'customer',
        },
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00.000Z',
      );

      final model = authService.buildUserModelForTesting(user, null);

      expect(model.id, 'user-003');
      expect(model.fullName, 'Rudi Hartono');
      expect(model.faculty, 'Fakultas Kedokteran');
      expect(model.bio, 'Asisten Lab Anatomi');
      expect(model.verificationStatus, KtmVerificationStatus.pending);
      expect(model.role, UserRole.customer);
    });
  });

  group('SupabaseProfileService Restricted Editable Payload', () {
    final profileService = SupabaseProfileService();

    test('buildEditableProfilePayload includes editable fields and strictly excludes sensitive fields', () {
      const user = UserModel(
        id: 'secure-user-456',
        fullName: 'Dewi Sartika',
        email: 'dewi@student.ub.ac.id',
        phoneNumber: '085711223344',
        nim: '225150201111002',
        avatarUrl: 'https://cdn.example.com/dewi.png',
        ktmPhotoUrl: 'https://cdn.example.com/dewi-ktm.png',
        verificationStatus: KtmVerificationStatus.verified,
        role: UserRole.provider,
        gender: UserGender.female,
        isFemaleOnlyPreferred: true,
        rewardPoints: 850,
        faculty: 'Fakultas Ekonomi dan Bisnis',
        bio: 'Fokus studi akuntansi dan keuangan publik',
      );

      final payload = profileService.buildEditableProfilePayload(user);

      expect(payload['id'], 'secure-user-456');
      expect(payload['email'], 'dewi@student.ub.ac.id');
      expect(payload['full_name'], 'Dewi Sartika');
      expect(payload['phone_number'], '085711223344');
      expect(payload['nim'], '225150201111002');
      expect(payload['avatar_url'], 'https://cdn.example.com/dewi.png');
      expect(payload['ktm_photo_url'], 'https://cdn.example.com/dewi-ktm.png');
      expect(payload['gender'], 'female');
      expect(payload['is_female_only_preferred'], true);
      expect(payload['faculty'], 'Fakultas Ekonomi dan Bisnis');
      expect(payload['bio'], 'Fokus studi akuntansi dan keuangan publik');
      expect(payload.containsKey('updated_at'), isTrue);

      expect(payload.containsKey('verification_status'), isFalse);
      expect(payload.containsKey('role'), isFalse);
      expect(payload.containsKey('reward_points'), isFalse);
    });
  });

  group('AppRouter Session Validation & Login Callback Security', () {
    setUp(() {
      AppAuthNotifier.instance.setLoggedIn(false);
      AppRouter.router.go(AppRouter.onboarding);
    });

    tearDown(() {
      AppAuthNotifier.instance.setLoggedIn(false);
    });

    test('AppRouter.hasActiveSession reflects AppAuthNotifier state', () {
      AppAuthNotifier.instance.setLoggedIn(false);
      expect(AppRouter.hasActiveSession(), isFalse);

      AppAuthNotifier.instance.setLoggedIn(true);
      expect(AppRouter.hasActiveSession(), isTrue);

      AppAuthNotifier.instance.setLoggedIn(false);
      expect(AppRouter.hasActiveSession(), isFalse);
    });

    testWidgets('AppRouter /login-callback redirects to /login when unauthenticated', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('ListTile background color')) return;
        originalOnError?.call(details);
      };

      AppAuthNotifier.instance.setLoggedIn(false);
      await tester.pumpWidget(const UbantuApp());
      await tester.pumpAndSettle();

      AppRouter.router.go(AppRouter.loginCallback);
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOneWidget);
      expect(find.byType(MainNavigationView), findsNothing);

      FlutterError.onError = originalOnError;
    });

    testWidgets('AppRouter /login-callback redirects to /home when authenticated', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('ListTile background color')) return;
        originalOnError?.call(details);
      };

      AppAuthNotifier.instance.setLoggedIn(true);
      await tester.pumpWidget(const UbantuApp());
      await tester.pumpAndSettle();

      AppRouter.router.go(AppRouter.loginCallback);
      await tester.pumpAndSettle();

      expect(find.byType(MainNavigationView), findsOneWidget);
      expect(find.byType(LoginView), findsNothing);

      FlutterError.onError = originalOnError;
    });
  });
}
