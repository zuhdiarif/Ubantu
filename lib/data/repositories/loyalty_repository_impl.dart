import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_loyalty_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/reward_points_model.dart';
import 'package:ubantu/domain/repositories/loyalty_repository.dart';
import 'package:ubantu/domain/repositories/session_scoped.dart';

class LoyaltyRepositoryImpl implements ILoyaltyRepository, SessionScoped {
  final SupabaseLoyaltyService _remoteService;
  final Map<String, RewardPointsModel> _mockUserPoints = {};
  final Set<String> _mockAwardedOrders = {};

  LoyaltyRepositoryImpl({SupabaseLoyaltyService? remoteService})
      : _remoteService = remoteService ?? SupabaseLoyaltyService();

  bool get hasRemoteService => true;
  SupabaseLoyaltyService get remoteService => _remoteService;
  bool get isRemoteActive => SupabaseService.instance.isInitialized;
  bool get _useSupabase => isRemoteActive;

  @override
  void clearSessionCache() {
    _mockUserPoints.clear();
    _mockAwardedOrders.clear();
  }

  RewardPointsModel _getOrCreateMockPoints(String userId) {
    return _mockUserPoints.putIfAbsent(
      userId,
      () => RewardPointsModel(
        userId: userId,
        totalPoints: 120,
        availableVouchers: 1,
        claimedVoucherCodes: const ['GRATIS1X_MOCK'],
      ),
    );
  }

  @override
  Future<AppResult<RewardPointsModel>> getLoyaltyPoints(String userId) async {
    if (_useSupabase) {
      return await _remoteService.getLoyaltyPoints(userId);
    }
    return AppResult.success(_getOrCreateMockPoints(userId));
  }

  @override
  Future<AppResult<RewardPointsModel>> claimVoucher(String userId, int pointsRequired) async {
    if (_useSupabase) {
      return await _remoteService.claimVoucher(userId, pointsRequired);
    }

    final current = _getOrCreateMockPoints(userId);
    if (current.totalPoints < pointsRequired) {
      return AppResult.failure('Poin kamu tidak mencukupi untuk klaim voucher ini');
    }

    final updated = current.copyWith(
      totalPoints: current.totalPoints - pointsRequired,
      availableVouchers: current.availableVouchers + 1,
      claimedVoucherCodes: [
        ...current.claimedVoucherCodes,
        'GRATIS1X_MOCK',
      ],
    );
    _mockUserPoints[userId] = updated;
    return AppResult.success(updated);
  }

  @override
  Future<AppResult<RewardPointsModel>> awardOrderPoints(String userId, String orderId) async {
    if (_useSupabase) {
      return await _remoteService.awardOrderPoints(orderId);
    }

    final current = _getOrCreateMockPoints(userId);
    if (_mockAwardedOrders.contains(orderId)) {
      return AppResult.success(current);
    }

    _mockAwardedOrders.add(orderId);
    final updated = current.copyWith(
      totalPoints: current.totalPoints + 10,
    );
    _mockUserPoints[userId] = updated;
    return AppResult.success(updated);
  }
}
