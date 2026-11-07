import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/services/supabase_storage_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/notification_repository.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';
import 'package:ubantu/domain/usecases/accept_order_usecase.dart';
import 'package:ubantu/domain/usecases/complete_order_with_proof_usecase.dart';
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
  final CompleteOrderWithProofUseCase _completeOrderWithProofUseCase;
  final SupabaseStorageService _storageService;
  final Map<String, Set<MoveServiceStatus>> _notifiedStatusTransitions = {};

  ServiceOrderProvider({
    required IServiceOrderRepository repository,
    INotificationRepository? notificationRepository,
    CompleteOrderWithProofUseCase? completeOrderWithProofUseCase,
    SupabaseStorageService? storageService,
  })  : _repository = repository,
        _notificationRepository = notificationRepository ?? ServiceLocator.instance.notificationRepository,
        _createOrderUseCase = CreateServiceOrderUseCase(repository),
        _getActiveOrdersUseCase = GetActiveOrdersUseCase(repository),
        _acceptOrderUseCase = AcceptOrderUseCase(repository),
        _updateOrderStatusUseCase = UpdateOrderStatusUseCase(repository),
        _completeOrderWithProofUseCase = completeOrderWithProofUseCase ?? CompleteOrderWithProofUseCase(repository),
        _storageService = storageService ?? SupabaseStorageService();

  List<ServiceOrderModel> _activeOrders = [];
  List<ServiceOrderModel> _myOrders = [];
  ServiceOrderModel? _activeOrder;
  StreamSubscription<ServiceOrderModel?>? _orderSubscription;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  String? _resolveCurrentUserName() {
    try {
      final user = ServiceLocator.instance.authRepository.getCurrentUser();
      if (user?.fullName != null && user!.fullName.trim().isNotEmpty) {
        return user.fullName.trim();
      }
    } catch (_) {}
    try {
      if (SupabaseService.instance.isInitialized) {
        final meta = SupabaseService.instance.client.auth.currentUser?.userMetadata;
        final raw = meta?['full_name'] as String? ?? meta?['name'] as String?;
        if (raw != null && raw.trim().isNotEmpty) {
          return raw.trim();
        }
      }
    } catch (_) {}
    return null;
  }

  void resetSession() {
    _orderSubscription?.cancel();
    _orderSubscription = null;
    _activeOrders = [];
    _myOrders = [];
    _activeOrder = null;
    _notifiedStatusTransitions.clear();
    _isLoading = false;
    _isSubmitting = false;
    _errorMessage = null;
    notifyListeners();
  }

  List<ServiceOrderModel> get activeOrders => List.unmodifiable(_activeOrders);
  List<ServiceOrderModel> get myOrders => List.unmodifiable(_myOrders);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  ServiceOrderModel? get activeOrder {
    if (_activeOrder != null) return _activeOrder;
    for (final o in _myOrders) {
      if (o.status != MoveServiceStatus.completed &&
          o.status != MoveServiceStatus.cancelled &&
          o.status != MoveServiceStatus.dibatalkan) {
        return o;
      }
    }
    return null;
  }

  void setActiveOrder(ServiceOrderModel? order) {
    _activeOrder = order;
    notifyListeners();
  }

  void clearActiveOrder() {
    _activeOrder = null;
    notifyListeners();
  }

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

  Future<bool> submitOrder({
    required ServiceOrderModel order,
    String? barterPhotoPath,
  }) async {
    _isSubmitting = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    String? photoUrl = order.barterPhotoUrl;

    if (barterPhotoPath != null && barterPhotoPath.isNotEmpty) {
      final uploadRes = await _storageService.uploadOrderPhoto(
        File(barterPhotoPath),
        order.category.name,
      );
      if (uploadRes.isFailure) {
        _errorMessage = uploadRes.errorOrNull ?? 'Gagal mengunggah foto barang.';
        _isSubmitting = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
      photoUrl = uploadRes.data;
    }

    final resolvedRequesterName = (order.requesterName != null && order.requesterName!.trim().isNotEmpty)
        ? order.requesterName
        : _resolveCurrentUserName();

    final orderWithRequesterName = resolvedRequesterName != null
        ? order.copyWith(requesterName: resolvedRequesterName)
        : order;

    final finalOrder = photoUrl != null
        ? orderWithRequesterName.copyWith(barterPhotoUrl: photoUrl)
        : orderWithRequesterName;

    final result = await _createOrderUseCase.execute(finalOrder);

    _isSubmitting = false;
    _isLoading = false;

    if (result.isSuccess) {
      final created = result.data!;
      _myOrders = [created, ..._myOrders];
      _activeOrder = created;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
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
    bool isFemaleOnly = false,
  }) async {
    _isLoading = true;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    String? uploadedUrl = photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty && !photoUrl.startsWith('http')) {
      final uploadRes = await _storageService.uploadOrderPhoto(
        File(photoUrl),
        ServiceCategory.pindahKos.name,
      );
      if (uploadRes.isFailure) {
        _errorMessage = uploadRes.errorOrNull ?? 'Gagal mengunggah foto barang.';
        _isSubmitting = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
      uploadedUrl = uploadRes.data;
    }

    final userId =
        SupabaseService.instance.isInitialized
            ? SupabaseService.instance.client.auth.currentUser?.id ?? ''
            : '';

    final order = ServiceOrderModel(
      id: '',
      requesterId: userId,
      requesterName: _resolveCurrentUserName(),
      category: ServiceCategory.pindahKos,
      status: MoveServiceStatus.waiting,
      locationOrigin: locationOrigin,
      locationDestination: locationDestination,
      scheduledAt: scheduledAt,
      itemDescription: itemDescription,
      barterType: barterType,
      barterDescription: barterDescription,
      barterPhotoUrl: uploadedUrl,
      vehicleType: vehicleType,
      weightKg: weightKg,
      isFemaleOnly: isFemaleOnly,
      createdAt: DateTime.now(),
    );

    final result = await _createOrderUseCase.execute(order);

    _isSubmitting = false;
    _isLoading = false;

    if (result.isSuccess) {
      final created = result.data!;
      _myOrders = [created, ..._myOrders];
      _activeOrder = created;
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
    bool isFemaleOnly = false,
  }) async {
    _isLoading = true;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    String? uploadedUrl = photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty && !photoUrl.startsWith('http')) {
      final uploadRes = await _storageService.uploadOrderPhoto(
        File(photoUrl),
        ServiceCategory.bersihKos.name,
      );
      if (uploadRes.isFailure) {
        _errorMessage = uploadRes.errorOrNull ?? 'Gagal mengunggah foto barang.';
        _isSubmitting = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
      uploadedUrl = uploadRes.data;
    }

    final userId = SupabaseService.instance.isInitialized
        ? SupabaseService.instance.client.auth.currentUser?.id ?? ''
        : '';

    final order = ServiceOrderModel(
      id: '',
      requesterId: userId,
      requesterName: _resolveCurrentUserName(),
      category: ServiceCategory.bersihKos,
      status: MoveServiceStatus.waiting,
      locationOrigin: locationKos,
      locationDestination: locationDestination ?? locationKos,
      scheduledAt: scheduledAt,
      itemDescription: jobDetail,
      barterType: barterType,
      barterDescription: barterDescription,
      barterPhotoUrl: uploadedUrl,
      isFemaleOnly: isFemaleOnly,
      createdAt: DateTime.now(),
    );

    final result = await _createOrderUseCase.execute(order);

    _isSubmitting = false;
    _isLoading = false;

    if (result.isSuccess) {
      final created = result.data!;
      _myOrders = [created, ..._myOrders];
      _activeOrder = created;
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
    String? receiverName,
    String? receiverPhone,
    VehicleType? vehicleType,
    double? weightKg,
    String? photoUrl,
    bool isFemaleOnly = false,
  }) async {
    _isLoading = true;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    String? uploadedUrl = photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty && !photoUrl.startsWith('http')) {
      final uploadRes = await _storageService.uploadOrderPhoto(
        File(photoUrl),
        ServiceCategory.antarJemput.name,
      );
      if (uploadRes.isFailure) {
        _errorMessage = uploadRes.errorOrNull ?? 'Gagal mengunggah foto barang.';
        _isSubmitting = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
      uploadedUrl = uploadRes.data;
    }

    final userId = SupabaseService.instance.isInitialized
        ? SupabaseService.instance.client.auth.currentUser?.id ?? ''
        : '';

    final order = ServiceOrderModel(
      id: '',
      requesterId: userId,
      requesterName: _resolveCurrentUserName(),
      category: ServiceCategory.antarJemput,
      status: MoveServiceStatus.waiting,
      locationOrigin: locationOrigin,
      locationDestination: locationDestination,
      scheduledAt: scheduledAt,
      itemDescription: itemDescription,
      barterType: barterType,
      barterDescription: barterDescription,
      barterPhotoUrl: uploadedUrl,
      vehicleType: vehicleType,
      weightKg: weightKg,
      isFemaleOnly: isFemaleOnly,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      createdAt: DateTime.now(),
    );

    final result = await _createOrderUseCase.execute(order);

    _isSubmitting = false;
    _isLoading = false;

    if (result.isSuccess) {
      final created = result.data!;
      _myOrders = [created, ..._myOrders];
      _activeOrder = created;
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

  Future<bool> completeOrderWithProof(String orderId, File photo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _completeOrderWithProofUseCase.execute(orderId, photo);

    _isLoading = false;

    if (result.isSuccess && result.data != null) {
      final updated = result.data!;
      _myOrders = _myOrders.map((o) => o.id == orderId ? updated : o).toList();
      final actIdx = _activeOrders.indexWhere((o) => o.id == orderId);
      if (actIdx != -1) {
        _activeOrders[actIdx] = updated;
      }
      _activeOrder = updated;
      _notifyOrderStatusChange(orderId, MoveServiceStatus.completed);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmBarter(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.confirmBarter(orderId);

    _isLoading = false;

    if (result.isSuccess && result.data != null) {
      final updated = result.data!;
      _myOrders = _myOrders.map((o) => o.id == orderId ? updated : o).toList();
      final actIdx = _activeOrders.indexWhere((o) => o.id == orderId);
      if (actIdx != -1) {
        _activeOrders[actIdx] = updated;
      }
      _activeOrder = updated;
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

  Future<bool> updateOrderNegotiation({
    required String orderId,
    required String barterDescription,
    String? locationOrigin,
    String? locationDestination,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (SupabaseService.instance.isInitialized) {
        final updatePayload = <String, dynamic>{
          'barter_description': barterDescription,
          if (locationOrigin != null && locationOrigin.isNotEmpty)
            'location_origin': locationOrigin,
          if (locationDestination != null && locationDestination.isNotEmpty)
            'location_destination': locationDestination,
        };
        await SupabaseService.instance.client
            .from('service_orders')
            .update(updatePayload)
            .eq('id', orderId);
      }

      final current = getOrderById(orderId);
      if (current != null) {
        final updated = current.copyWith(
          barterDescription: barterDescription,
          locationOrigin: (locationOrigin != null && locationOrigin.isNotEmpty)
              ? locationOrigin
              : current.locationOrigin,
          locationDestination:
              (locationDestination != null && locationDestination.isNotEmpty)
                  ? locationDestination
                  : current.locationDestination,
        );
        final idx = _myOrders.indexWhere((o) => o.id == orderId);
        if (idx != -1) {
          _myOrders[idx] = updated;
        }
        final actIdx = _activeOrders.indexWhere((o) => o.id == orderId);
        if (actIdx != -1) {
          _activeOrders[actIdx] = updated;
        }
        if (_activeOrder?.id == orderId) {
          _activeOrder = updated;
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
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

  void subscribeToOrder(String orderId) {
    _orderSubscription?.cancel();
    _orderSubscription = _repository.watchOrder(orderId).listen((order) {
      if (order != null) {
        _activeOrder = order;
        final idx = _myOrders.indexWhere((o) => o.id == orderId);
        if (idx != -1) {
          _myOrders[idx] = order;
        } else {
          _myOrders.insert(0, order);
        }
        final actIdx = _activeOrders.indexWhere((o) => o.id == orderId);
        if (actIdx != -1) {
          _activeOrders[actIdx] = order;
        }
        _notifyOrderStatusChange(orderId, order.status);
        notifyListeners();
      }
    });
  }

  void cancelOrderSubscription() {
    _orderSubscription?.cancel();
    _orderSubscription = null;
  }

  @override
  void dispose() {
    cancelOrderSubscription();
    super.dispose();
  }
}
