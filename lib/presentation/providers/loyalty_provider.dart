import 'package:flutter/material.dart';
import 'package:ubantu/data/repositories/loyalty_repository_impl.dart';
import 'package:ubantu/domain/models/reward_points_model.dart';
import 'package:ubantu/domain/repositories/loyalty_repository.dart';
import 'package:ubantu/domain/usecases/claim_reward_usecase.dart';

class LoyaltyProvider extends ChangeNotifier {
  final ILoyaltyRepository _repository;
  final ClaimRewardUseCase _claimRewardUseCase;

  LoyaltyProvider({ILoyaltyRepository? repository})
      : _repository = repository ?? LoyaltyRepositoryImpl(),
        _claimRewardUseCase = ClaimRewardUseCase(repository ?? LoyaltyRepositoryImpl());

  RewardPointsModel? _pointsData;
  bool _isLoading = false;
  String? _errorMessage;

  RewardPointsModel? get pointsData => _pointsData;
  int get totalPoints => _pointsData?.totalPoints ?? 0;
  int get availableVouchers => _pointsData?.availableVouchers ?? 0;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  Future<bool> claimVoucher(String userId, int pointsRequired) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

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
  }
}
