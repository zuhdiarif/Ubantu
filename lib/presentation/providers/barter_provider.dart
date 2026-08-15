import 'package:flutter/material.dart';
import 'package:ubantu/data/repositories/barter_repository_impl.dart';
import 'package:ubantu/domain/models/barter_item_model.dart';
import 'package:ubantu/domain/repositories/barter_repository.dart';
import 'package:ubantu/domain/usecases/get_barter_items_usecase.dart';

class BarterProvider extends ChangeNotifier {
  final GetBarterItemsUseCase _getBarterItemsUseCase;

  BarterProvider({IBarterRepository? repository})
      : _getBarterItemsUseCase =
            GetBarterItemsUseCase(repository ?? BarterRepositoryImpl());

  List<BarterItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

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
