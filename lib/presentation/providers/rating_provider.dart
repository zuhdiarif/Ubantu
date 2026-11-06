import 'package:flutter/material.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/domain/models/rating_model.dart';
import 'package:ubantu/domain/repositories/rating_repository.dart';

class RatingProvider extends ChangeNotifier {
  final IRatingRepository _repository;

  RatingProvider({IRatingRepository? repository})
      : _repository = repository ?? ServiceLocator.instance.ratingRepository;

  IRatingRepository get repository => _repository;

  List<RatingModel> _ratings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RatingModel> get ratings => List.unmodifiable(_ratings);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRatings(String targetUserId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getRatings(targetUserId);
    if (result.isSuccess) {
      _ratings = result.data ?? [];
    } else {
      _errorMessage = result.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitRating(String targetUserId, double score, String reviewText) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.addRating(targetUserId, score, reviewText);
    _isLoading = false;

    if (result.isSuccess && result.data != null) {
      _ratings.insert(0, result.data!);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage ?? 'Gagal mengirim ulasan';
      notifyListeners();
      return false;
    }
  }
}
