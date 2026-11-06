import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/loyalty_repository_impl.dart';
import 'package:ubantu/domain/models/reward_points_model.dart';
import 'package:ubantu/domain/repositories/loyalty_repository.dart';
import 'package:ubantu/domain/usecases/award_order_points_usecase.dart';
import 'package:ubantu/domain/usecases/claim_reward_usecase.dart';
import 'package:ubantu/presentation/providers/loyalty_provider.dart';

class _SlowClaimLoyaltyRepository implements ILoyaltyRepository {
  final Completer<void> gate = Completer<void>();
  int claimCalls = 0;

  @override
  Future<AppResult<RewardPointsModel>> getLoyaltyPoints(String userId) async {
    return AppResult.success(RewardPointsModel(userId: userId, totalPoints: 200, availableVouchers: 0));
  }

  @override
  Future<AppResult<RewardPointsModel>> claimVoucher(String userId, int pointsRequired) async {
    claimCalls++;
    await gate.future;
    return AppResult.success(RewardPointsModel(userId: userId, totalPoints: 100, availableVouchers: 1));
  }

  @override
  Future<AppResult<RewardPointsModel>> awardOrderPoints(String userId, String orderId) async {
    return AppResult.success(RewardPointsModel(userId: userId, totalPoints: 210, availableVouchers: 0));
  }
}

void main() {
  group('LoyaltyRepositoryImpl Offline Mock Tests', () {
    test('awardOrderPoints is idempotent per orderId (+10 once)', () async {
      final repo = LoyaltyRepositoryImpl();
      final user = 'user_abc';

      final initial = await repo.getLoyaltyPoints(user);
      expect(initial.isSuccess, isTrue);
      expect(initial.data?.totalPoints, 120);

      final firstAward = await repo.awardOrderPoints(user, 'order_100');
      expect(firstAward.isSuccess, isTrue);
      expect(firstAward.data?.totalPoints, 130);

      final secondAward = await repo.awardOrderPoints(user, 'order_100');
      expect(secondAward.isSuccess, isTrue);
      expect(secondAward.data?.totalPoints, 130);

      final thirdAward = await repo.awardOrderPoints(user, 'order_200');
      expect(thirdAward.isSuccess, isTrue);
      expect(thirdAward.data?.totalPoints, 140);
    });

    test('claimVoucher fails with insufficient points and succeeds when sufficient', () async {
      final repo = LoyaltyRepositoryImpl();
      final user = 'user_xyz';

      final failed = await repo.claimVoucher(user, 500);
      expect(failed.isSuccess, isFalse);
      expect(failed.errorMessage, contains('tidak mencukupi'));

      final success = await repo.claimVoucher(user, 100);
      expect(success.isSuccess, isTrue);
      expect(success.data?.totalPoints, 20);
      expect(success.data?.availableVouchers, 2);

      final secondClaim = await repo.claimVoucher(user, 100);
      expect(secondClaim.isSuccess, isFalse);
      expect(secondClaim.errorMessage, contains('tidak mencukupi'));
    });

    test('clearSessionCache wipes in-memory per-user cache and awarded orders', () async {
      final repo = LoyaltyRepositoryImpl();
      final user = 'user_session';

      final award = await repo.awardOrderPoints(user, 'order_session_1');
      expect(award.data?.totalPoints, 130);

      repo.clearSessionCache();

      final reset = await repo.getLoyaltyPoints(user);
      expect(reset.data?.totalPoints, 120);

      final reAward = await repo.awardOrderPoints(user, 'order_session_1');
      expect(reAward.data?.totalPoints, 130);
    });
  });

  group('AwardOrderPointsUseCase Tests', () {
    test('delegates awardOrderPoints to repository', () async {
      final repo = LoyaltyRepositoryImpl();
      final useCase = AwardOrderPointsUseCase(repo);

      final res = await useCase.execute('user_uc', 'ord_uc_1');
      expect(res.isSuccess, isTrue);
      expect(res.data?.totalPoints, 130);
    });
  });

  group('LoyaltyProvider Tests', () {
    test('awardOrderPoints updates pointsData and returns true', () async {
      final repo = LoyaltyRepositoryImpl();
      final provider = LoyaltyProvider(repository: repo);

      final success = await provider.awardOrderPoints('usr_p', 'ord_p_1');
      expect(success, isTrue);
      expect(provider.totalPoints, 130);
      expect(provider.isLoading, isFalse);
    });

    test('ignores a second concurrent claim while first is in flight', () async {
      final slowRepo = _SlowClaimLoyaltyRepository();
      final provider = LoyaltyProvider(
        repository: slowRepo,
        claimRewardUseCase: ClaimRewardUseCase(slowRepo),
      );

      final firstClaimFuture = provider.claimVoucher('usr_race', 100);
      expect(provider.isClaiming, isTrue);

      final secondClaimFuture = provider.claimVoucher('usr_race', 100);
      final secondClaimResult = await secondClaimFuture;
      expect(secondClaimResult, isFalse);
      expect(slowRepo.claimCalls, 1);

      slowRepo.gate.complete();
      final firstClaimResult = await firstClaimFuture;
      expect(firstClaimResult, isTrue);
      expect(provider.isClaiming, isFalse);
      expect(provider.availableVouchers, 1);
    });

    test('resetSession clears state and notifies listeners', () async {
      final repo = LoyaltyRepositoryImpl();
      final provider = LoyaltyProvider(repository: repo);

      await provider.loadLoyaltyPoints('usr_reset');
      expect(provider.pointsData, isNotNull);

      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.resetSession();
      expect(notified, isTrue);
      expect(provider.pointsData, isNull);
      expect(provider.account, isNull);
      expect(provider.totalPoints, 0);
      expect(provider.availableVouchers, 0);
      expect(provider.isLoading, isFalse);
      expect(provider.isClaiming, isFalse);
      expect(provider.errorMessage, isNull);
    });
  });
}
