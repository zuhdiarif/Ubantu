import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/data/services/supabase_storage_service.dart';
import 'package:ubantu/data/models/reward_points_model.dart';
import 'package:ubantu/data/repositories/loyalty_repository.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/ui/auth/auth_provider.dart';
import 'package:ubantu/ui/profile/loyalty_provider.dart';
import 'package:ubantu/ui/auth/password_reset_provider.dart';
import 'package:ubantu/ui/auth/forgot_password_view.dart';
import 'package:ubantu/ui/auth/login_view.dart';

class _MockLoyaltyRepo implements ILoyaltyRepository {
  int points = 120;
  int vouchers = 1;

  @override
  Future<AppResult<RewardPointsModel>> getLoyaltyPoints(String userId) async {
    return AppResult.success(RewardPointsModel(
      userId: userId,
      totalPoints: points,
      availableVouchers: vouchers,
      claimedVoucherCodes: const ['MOCK1'],
    ));
  }

  @override
  Future<AppResult<RewardPointsModel>> claimVoucher(String userId, int pointsRequired) async {
    if (points >= pointsRequired) {
      points -= pointsRequired;
      vouchers += 1;
      return AppResult.success(RewardPointsModel(
        userId: userId,
        totalPoints: points,
        availableVouchers: vouchers,
        claimedVoucherCodes: const ['MOCK1', 'MOCK_CLAIMED'],
      ));
    }
    return AppResult.failure('Poin tidak cukup');
  }

  @override
  Future<AppResult<RewardPointsModel>> awardOrderPoints(String userId, String orderId) async {
    points += 10;
    return AppResult.success(RewardPointsModel(
      userId: userId,
      totalPoints: points,
      availableVouchers: vouchers,
      claimedVoucherCodes: const ['MOCK1'],
    ));
  }
}

void main() {
  group('Squad 3 Feature Activation Tests', () {
    test('LoyaltyProvider supports fetchLoyaltyAccount, account and claimVoucher default', () async {
      final repo = _MockLoyaltyRepo();
      final provider = LoyaltyProvider(repository: repo);

      await provider.fetchLoyaltyAccount('usr_1');
      expect(provider.account, isNotNull);
      expect(provider.account?.totalPoints, 120);
      expect(provider.account?.availableVouchers, 1);
      expect(provider.totalPoints, 120);

      final claimSuccess = await provider.claimVoucher('usr_1');
      expect(claimSuccess, isTrue);
      expect(provider.totalPoints, 20);
      expect(provider.availableVouchers, 2);
    });

    test('SupabaseStorageService uploadChatAttachment returns failure when uninitialized', () async {
      final storageService = SupabaseStorageService();
      final tempFile = File('temp_test.png');
      await tempFile.writeAsBytes([1, 2, 3]);
      try {
        final result = await storageService.uploadChatAttachment(tempFile, 'room_123');
        expect(result.isFailure, isTrue);
        expect(result.isSuccess, isFalse);
      } finally {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    });

    test('ServiceLocator provides SupabaseStorageService instance', () {
      expect(ServiceLocator.instance.supabaseStorageService, isNotNull);
    });

    testWidgets('LoginView renders Lupa Password button and navigates to forgot password view', (tester) async {
      final router = GoRouter(
        initialLocation: AppRouter.login,
        routes: [
          GoRoute(
            path: AppRouter.login,
            builder: (context, state) => const LoginView(),
          ),
          GoRoute(
            path: AppRouter.forgotPassword,
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) => PasswordResetProvider(),
              child: const ForgotPasswordView(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final forgotPasswordFinder = find.text('Lupa password ?');
      expect(forgotPasswordFinder, findsOneWidget);

      await tester.tap(forgotPasswordFinder);
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordView), findsOneWidget);
      expect(find.text('Atur Ulang Kata Sandi'), findsOneWidget);
    });
  });
}
