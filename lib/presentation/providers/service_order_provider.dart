import 'package:flutter/material.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/notification_repository.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';
import 'package:ubantu/domain/usecases/accept_order_usecase.dart';
import 'package:ubantu/domain/usecases/create_service_order_usecase.dart';
import 'package:ubantu/domain/usecases/get_active_orders_usecase.dart';
import 'package:ubantu/domain/usecases/update_order_status_usecase.dart';

class ServiceOrderProvider extends ChangeNotifier {
  final IServiceOrderRepository _repository;
  final INotificationRepository _notificationRepository;
  final CreateServiceOrderUseCase _createOrderUseCase;
  final GetActiveOrdersUseCase _getActiveOrdersUseCase;
  final AcceptOrderUseCase _acceptOrderUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  final Map<String, Set<MoveServiceStatus>> _notifiedStatusTransitions = {};

  ServiceOrderProvider({
    required IServiceOrderRepository repository,
    INotificationRepository? notificationRepository,
  })  : _repository = repository,
        _notificationRepository = notificationRepository ?? ServiceLocator.instance.notificationRepository,
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
    String? photoUrl,
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
      barterPhotoUrl: photoUrl,
      vehicleType: vehicleType,
      weightKg: weightKg,
      createdAt: DateTime.now(),
    );

    final result = await _createOrderUseCase.execute(order);

    _isLoading = false;

    if (result.isSuccess) {
      _myOrders = [result.data!, ..._myOrders];
      _activeOrders = [result.data!, ..._activeOrders];
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
      _activeOrders = [result.data!, ..._activeOrders];
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
      _activeOrders = [result.data!, ..._activeOrders];
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
      _notifyOrderStatusChange(orderId, status);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  void _notifyOrderStatusChange(String orderId, MoveServiceStatus newStatus) {
    final notifiedSet = _notifiedStatusTransitions.putIfAbsent(
      orderId,
      () => <MoveServiceStatus>{},
    );
    if (notifiedSet.contains(newStatus)) return;
    notifiedSet.add(newStatus);

    final prefix = orderId.length > 6
        ? '#UB-${orderId.substring(0, 6).toUpperCase()}'
        : '#UB-ORDER';

    if (newStatus == MoveServiceStatus.inProgress) {
      _notificationRepository.addNotification(
        'Driver Sudah Tiba di Lokasi!',
        'Driver/Helper telah tiba di titik jemput untuk pesanan $prefix. Segera temui penolongmu ya!',
        type: 'order',
      );
    } else if (newStatus == MoveServiceStatus.completed) {
      _notificationRepository.addNotification(
        'Pesanan Bantuan Selesai',
        'Pesanan bantuan $prefix telah selesai dilaksanakan. Terima kasih telah menggunakan UBantu!',
        type: 'order',
      );
    }
  }

  ServiceOrderModel? getOrderById(String orderId) {
    try {
      return _myOrders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      try {
        return _activeOrders.firstWhere((o) => o.id == orderId);
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> refreshActiveOrders() async {
    final result = await _getActiveOrdersUseCase.execute();
    if (result.isSuccess && result.data != null) {
      _activeOrders = result.data!;
      notifyListeners();
    }
  }

  Future<void> refreshMyOrders([String? userId]) async {
    final uid = userId ??
        (SupabaseService.instance.isInitialized
            ? SupabaseService.instance.client.auth.currentUser?.id ?? ''
            : '');
    final result = await _repository.getOrderHistory(uid);
    if (result.isSuccess && result.data != null) {
      _myOrders = result.data!;
      notifyListeners();
    }
  }

  Future<ServiceOrderModel?> checkOrderStatus(String orderId) async {
    if (SupabaseService.instance.isInitialized) {
      try {
        final res = await SupabaseService.instance.client
            .from('service_orders')
            .select()
            .eq('id', orderId)
            .maybeSingle();
        if (res != null) {
          final updated = ServiceOrderModel.fromJson(res);
          final idx = _myOrders.indexWhere((o) => o.id == orderId);
          if (idx != -1) {
            _myOrders[idx] = updated;
          } else {
            _myOrders.insert(0, updated);
          }
          _activeOrders = _activeOrders.where((o) => o.id != orderId).toList();
          _notifyOrderStatusChange(orderId, updated.status);
          notifyListeners();
          return updated;
        }
      } catch (_) {}
    }
    return getOrderById(orderId);
  }
}

