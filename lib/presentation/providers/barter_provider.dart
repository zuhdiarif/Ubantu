import 'package:flutter/material.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/domain/models/barter_item_model.dart';
import 'package:ubantu/domain/repositories/barter_repository.dart';
import 'package:ubantu/domain/usecases/get_barter_items_usecase.dart';

class BarterProvider extends ChangeNotifier {
  final IBarterRepository _repository;
  final GetBarterItemsUseCase _getBarterItemsUseCase;

  BarterProvider({IBarterRepository? repository})
      : _repository = repository ?? ServiceLocator.instance.barterRepository,
        _getBarterItemsUseCase =
            GetBarterItemsUseCase(repository ?? ServiceLocator.instance.barterRepository);

  IBarterRepository get repository => _repository;

  List<BarterItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  void resetSession() {
    _items = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  List<BarterItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBarterItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getBarterItemsUseCase.execute();
    if (result.isSuccess) {
      _items = result.data ?? [];
    } else {
      _errorMessage = result.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
  }
}
