import 'package:flutter/material.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/data/models/reward_points_model.dart';
import 'package:ubantu/data/repositories/loyalty_repository.dart';
import 'package:ubantu/logic/award_order_points_usecase.dart';
import 'package:ubantu/logic/claim_reward_usecase.dart';

class LoyaltyProvider extends ChangeNotifier {
  final ILoyaltyRepository _repository;
  final ClaimRewardUseCase _claimRewardUseCase;
  final AwardOrderPointsUseCase _awardOrderPointsUseCase;

  LoyaltyProvider({
    ILoyaltyRepository? repository,
    ClaimRewardUseCase? claimRewardUseCase,
    AwardOrderPointsUseCase? awardOrderPointsUseCase,
  })  : _repository = repository ?? ServiceLocator.instance.loyaltyRepository,
        _claimRewardUseCase = claimRewardUseCase ??
            ClaimRewardUseCase(repository ?? ServiceLocator.instance.loyaltyRepository),
        _awardOrderPointsUseCase = awardOrderPointsUseCase ??
            AwardOrderPointsUseCase(repository ?? ServiceLocator.instance.loyaltyRepository);

  ILoyaltyRepository get repository => _repository;

  RewardPointsModel? _pointsData;
  bool _isLoading = false;
  bool _isClaiming = false;
  String? _errorMessage;

  RewardPointsModel? get pointsData => _pointsData;
  RewardPointsModel? get account => _pointsData;
  int get totalPoints => _pointsData?.totalPoints ?? 0;
  int get availableVouchers => _pointsData?.availableVouchers ?? 0;
  bool get isLoading => _isLoading;
  bool get isClaiming => _isClaiming;
  String? get errorMessage => _errorMessage;

  void resetSession() {
    _pointsData = null;
    _isLoading = false;
    _isClaiming = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadLoyaltyPoints(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getLoyaltyPoints(userId);
    if (result.isSuccess) {
      _pointsData = result.data;
    } else {
      _errorMessage = result.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchLoyaltyAccount(String userId) => loadLoyaltyPoints(userId);

  Future<bool> claimVoucher(String userId, [int pointsRequired = 100]) async {
    if (_isClaiming) return false;
    _isClaiming = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _claimRewardUseCase.execute(userId, pointsRequired);
      _isLoading = false;

      if (result.isSuccess && result.data != null) {
        _pointsData = result.data;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.errorMessage ?? 'Gagal mengklaim voucher';
        notifyListeners();
        return false;
      }
    } finally {
      _isClaiming = false;
    }
  }

  Future<bool> awardOrderPoints(String userId, String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _awardOrderPointsUseCase.execute(userId, orderId);
    _isLoading = false;

    if (result.isSuccess && result.data != null) {
      _pointsData = result.data;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage ?? 'Gagal menambahkan poin';
      notifyListeners();
      return false;
    }
  }
}
