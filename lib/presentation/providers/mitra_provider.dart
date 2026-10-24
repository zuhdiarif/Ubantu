import 'package:flutter/material.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/mitra_earning_item_model.dart';
import 'package:ubantu/domain/models/mitra_profile_model.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/data/repositories/mitra_repository_impl.dart';
import 'package:ubantu/domain/repositories/mitra_repository.dart';

class MitraProvider extends ChangeNotifier {
  final IMitraRepository _repository;

  MitraProvider({IMitraRepository? repository})
      : _repository = repository ?? MitraRepositoryImpl();

  MitraProfileModel? _profile;
  List<ServiceOrderModel> _incomingOrders = [];
  ServiceOrderModel? _activeOrder;
  List<ServiceOrderModel> _completedOrders = [];
  List<MitraEarningItemModel> _earningsHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  MitraProfileModel? get profile => _profile;
  List<ServiceOrderModel> get incomingOrders =>
      List.unmodifiable(_incomingOrders);
  ServiceOrderModel? get activeOrder => _activeOrder;
  List<ServiceOrderModel> get completedOrders =>
      List.unmodifiable(_completedOrders);
  List<MitraEarningItemModel> get earningsHistory =>
      List.unmodifiable(_earningsHistory);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isOnline => _profile?.isOnline ?? true;

  Future<void> loadMitraData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final profileRes = await _repository.getMitraProfile();
    if (profileRes.isSuccess && profileRes.data != null) {
      _profile = profileRes.data;
    }

    final incomingRes = await _repository.getIncomingOrders();
    if (incomingRes.isSuccess && incomingRes.data != null) {
      _incomingOrders = incomingRes.data!;
    }

    final activeRes = await _repository.getActiveOrder();
    if (activeRes.isSuccess) {
      _activeOrder = activeRes.data;
    }

    final completedRes = await _repository.getCompletedOrders();
    if (completedRes.isSuccess && completedRes.data != null) {
      _completedOrders = completedRes.data!;
    }

    final earningsRes = await _repository.getEarningsHistory();
    if (earningsRes.isSuccess && earningsRes.data != null) {
      _earningsHistory = earningsRes.data!;
    }

    _isLoading = false;
    notifyListeners();
  }

  void setActiveOrder(ServiceOrderModel? order) {
    _activeOrder = order;
    notifyListeners();
  }

  Future<void> toggleOnlineStatus(bool value) async {
    final result = await _repository.toggleOnlineStatus(value);
    if (result.isSuccess) {
      _profile = _profile?.copyWith(isOnline: value);
      notifyListeners();
    }
  }

  Future<void> updateCategories(List<ServiceCategory> categories) async {
    final result = await _repository.updateServiceCategories(categories);
    if (result.isSuccess) {
      _profile = _profile?.copyWith(selectedCategories: categories);
      notifyListeners();
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.acceptOrder(orderId);
    _isLoading = false;

    if (result.isSuccess) {
      await loadMitraData();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> declineOrder(String orderId) async {
    final result = await _repository.declineOrder(orderId);
    if (result.isSuccess) {
      _incomingOrders =
          _incomingOrders.where((order) => order.id != orderId).toList();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateActiveOrderStatus(MoveServiceStatus status) async {
    if (_activeOrder == null) return false;

    _isLoading = true;
    notifyListeners();

    final result = await _repository.updateOrderStatus(_activeOrder!.id, status);
    _isLoading = false;

    if (result.isSuccess) {
      await loadMitraData();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> advanceActiveOrderStatus() async {
    if (_activeOrder == null) return false;

    if (_activeOrder!.status == MoveServiceStatus.accepted) {
      return updateActiveOrderStatus(MoveServiceStatus.inProgress);
    } else if (_activeOrder!.status == MoveServiceStatus.inProgress) {
      return updateActiveOrderStatus(MoveServiceStatus.completed);
    }
    return false;
  }
}
