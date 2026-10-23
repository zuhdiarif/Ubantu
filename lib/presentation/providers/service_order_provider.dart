import 'package:flutter/material.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';
import 'package:ubantu/domain/usecases/accept_order_usecase.dart';
import 'package:ubantu/domain/usecases/create_service_order_usecase.dart';
import 'package:ubantu/domain/usecases/get_active_orders_usecase.dart';
import 'package:ubantu/domain/usecases/update_order_status_usecase.dart';

class ServiceOrderProvider extends ChangeNotifier {
  final IServiceOrderRepository _repository;
  final CreateServiceOrderUseCase _createOrderUseCase;
  final GetActiveOrdersUseCase _getActiveOrdersUseCase;
  final AcceptOrderUseCase _acceptOrderUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

  ServiceOrderProvider({required IServiceOrderRepository repository})
      : _repository = repository,
        _createOrderUseCase = CreateServiceOrderUseCase(repository),
        _getActiveOrdersUseCase = GetActiveOrdersUseCase(repository),
        _acceptOrderUseCase = AcceptOrderUseCase(repository),
        _updateOrderStatusUseCase = UpdateOrderStatusUseCase(repository);

  List<ServiceOrderModel> _activeOrders = [];
  List<ServiceOrderModel> _myOrders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ServiceOrderModel> get activeOrders => List.unmodifiable(_activeOrders);
  List<ServiceOrderModel> get myOrders => List.unmodifiable(_myOrders);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadActiveOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getActiveOrdersUseCase.execute();
    if (result.isSuccess) {
      _activeOrders = result.data ?? [];
    } else {
      _errorMessage = result.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyOrders(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getOrderHistory(userId);
    if (result.isSuccess) {
      _myOrders = result.data ?? [];
    } else {
      _errorMessage = result.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPindahKosOrder({
    required String locationOrigin,
    required String locationDestination,
    required VehicleType vehicleType,
    required double weightKg,
    required String itemDescription,
    required DateTime scheduledAt,
    required BarterType barterType,
    required String barterDescription,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final userId =
        SupabaseService.instance.isInitialized
            ? SupabaseService.instance.client.auth.currentUser?.id ?? ''
            : '';

    final order = ServiceOrderModel(
      id: '',
      requesterId: userId,
      category: ServiceCategory.pindahKos,
      status: MoveServiceStatus.waiting,
      locationOrigin: locationOrigin,
      locationDestination: locationDestination,
      scheduledAt: scheduledAt,
      itemDescription: itemDescription,
      barterType: barterType,
      barterDescription: barterDescription,
      vehicleType: vehicleType,
      weightKg: weightKg,
      createdAt: DateTime.now(),
    );

    final result = await _createOrderUseCase.execute(order);

    _isLoading = false;

    if (result.isSuccess) {
      _myOrders = [result.data!, ..._myOrders];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createBersihKosOrder({
    required String locationKos,
    required String jobDetail,
    required DateTime scheduledAt,
    required BarterType barterType,
    required String barterDescription,
    String? photoUrl,
    String? locationDestination,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final userId = SupabaseService.instance.isInitialized
        ? SupabaseService.instance.client.auth.currentUser?.id ?? ''
        : '';

    final order = ServiceOrderModel(
      id: '',
      requesterId: userId,
      category: ServiceCategory.bersihKos,
      status: MoveServiceStatus.waiting,
      locationOrigin: locationKos,
      locationDestination: locationDestination ?? locationKos,
      scheduledAt: scheduledAt,
      itemDescription: jobDetail,
      barterType: barterType,
      barterDescription: barterDescription,
      barterPhotoUrl: photoUrl,
      createdAt: DateTime.now(),
    );

    final result = await _createOrderUseCase.execute(order);

    _isLoading = false;

    if (result.isSuccess) {
      _myOrders = [result.data!, ..._myOrders];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createAntarJemputOrder({
    required String locationOrigin,
    required String locationDestination,
    required String itemDescription,
    required DateTime scheduledAt,
    required BarterType barterType,
    required String barterDescription,
    VehicleType? vehicleType,
    double? weightKg,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final userId = SupabaseService.instance.isInitialized
        ? SupabaseService.instance.client.auth.currentUser?.id ?? ''
        : '';

    final order = ServiceOrderModel(
      id: '',
      requesterId: userId,
      category: ServiceCategory.antarJemput,
      status: MoveServiceStatus.waiting,
      locationOrigin: locationOrigin,
      locationDestination: locationDestination,
      scheduledAt: scheduledAt,
      itemDescription: itemDescription,
      barterType: barterType,
      barterDescription: barterDescription,
      barterPhotoUrl: photoUrl,
      vehicleType: vehicleType,
      weightKg: weightKg,
      createdAt: DateTime.now(),
    );

    final result = await _createOrderUseCase.execute(order);

    _isLoading = false;

    if (result.isSuccess) {
      _myOrders = [result.data!, ..._myOrders];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final helperId = SupabaseService.instance.isInitialized
        ? SupabaseService.instance.client.auth.currentUser?.id ?? ''
        : '';

    final result = await _acceptOrderUseCase.execute(orderId, helperId);

    _isLoading = false;

    if (result.isSuccess) {
      _activeOrders = _activeOrders.where((o) => o.id != orderId).toList();
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(String orderId, MoveServiceStatus status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _updateOrderStatusUseCase.execute(orderId, status);

    _isLoading = false;

    if (result.isSuccess) {
      final updated = result.data!;
      _myOrders = _myOrders.map((o) => o.id == orderId ? updated : o).toList();
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }
}
