import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';

class SupabaseOrderService {
  static const String _table = 'service_orders';

  static List<ServiceOrderModel> _defaultWaitingOrders() => [
    ServiceOrderModel(
      id: 'ord-mitra-01',
      requesterId: 'req_mahasiswa_1',
      category: ServiceCategory.pindahKos,
      status: MoveServiceStatus.waiting,
      locationOrigin: 'Kos Griya UB, Jl. Watugong No. 12',
      locationDestination: 'Kos Permata, Jl. Sigura-gura IV',
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      itemDescription: '3 Kardus buku, 1 koper pakaian, dan dispenser kecil',
      barterType: BarterType.makanan,
      barterDescription: 'Nasi Padang Ampera + Es Teh Manis',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    ServiceOrderModel(
      id: 'ord-mitra-02',
      requesterId: 'req_mahasiswa_2',
      category: ServiceCategory.bersihKos,
      status: MoveServiceStatus.waiting,
      locationOrigin: 'Kos Melati Indah, Jl. Kerto Raharjo No. 8',
      locationDestination: 'Kos Melati Indah, Jl. Kerto Raharjo No. 8',
      scheduledAt: DateTime.now().add(const Duration(hours: 4)),
      itemDescription:
          'Sapu & pel lantai kamar kos (3x4m) dan buang kardus sampah pindahan',
      barterType: BarterType.makanan,
      barterDescription: 'Ayam Geprek Kak Rose Level 2 + Jus Alpukat',
      createdAt: DateTime.now().subtract(const Duration(minutes: 32)),
    ),
    ServiceOrderModel(
      id: 'ord-mitra-03',
      requesterId: 'req_mahasiswa_3',
      category: ServiceCategory.antarJemput,
      status: MoveServiceStatus.waiting,
      locationOrigin: 'Gerbang Veteran UB',
      locationDestination: 'Stasiun Malang Kota Baru',
      scheduledAt: DateTime.now().add(const Duration(hours: 5)),
      itemDescription:
          'Tebengan motor bawa 1 ransel sedang ke stasiun sore hari',
      barterType: BarterType.barang,
      barterDescription: 'Voucher Kopi Kenangan 25rb / Kuota Indosat',
      createdAt: DateTime.now().subtract(const Duration(minutes: 48)),
    ),
  ];

  final List<ServiceOrderModel> _fallbackWaitingOrders = _defaultWaitingOrders();

  Future<AppResult<List<ServiceOrderModel>>> getActiveOrders() async {
    try {
      if (SupabaseService.instance.isInitialized) {
        final response = await SupabaseService.instance.client
            .from(_table)
            .select()
            .eq('status', MoveServiceStatus.waiting.name)
            .order('created_at', ascending: false);

        final orders = response
            .map((e) => ServiceOrderModel.fromJson(e))
            .toList();
        return AppResult.success(orders);
      }
      return AppResult.success(List.from(_fallbackWaitingOrders));
    } catch (e) {
      if (SupabaseService.instance.isInitialized) {
        return AppResult.failure('Gagal memuat pesanan aktif: $e');
      }
      return AppResult.success(List.from(_fallbackWaitingOrders));
    }
  }

  Future<AppResult<List<ServiceOrderModel>>> getOrderHistory(
    String userId,
  ) async {
    try {
      final response = await SupabaseService.instance.client
          .from(_table)
          .select()
          .or('requester_id.eq.$userId,helper_id.eq.$userId')
          .order('created_at', ascending: false);

      final orders = response
          .map((e) => ServiceOrderModel.fromJson(e))
          .toList();
      return AppResult.success(orders);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<ServiceOrderModel>> createOrder(
    ServiceOrderModel order,
  ) async {
    try {
      final data = order.toJson()..remove('id');
      data.removeWhere((key, value) => value == null);

      final response = await SupabaseService.instance.client
          .from(_table)
          .insert(data)
          .select()
          .single();

      return AppResult.success(
        ServiceOrderModel.fromJson(response),
      );
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  final Map<String, StreamController<ServiceOrderModel?>> _mockOrderControllers = {};

  StreamController<ServiceOrderModel?> _getOrCreateMockController(String orderId) {
    return _mockOrderControllers.putIfAbsent(
      orderId,
      () => StreamController<ServiceOrderModel?>.broadcast(),
    );
  }

  Stream<ServiceOrderModel?> _mockOrderStream(String orderId) async* {
    final fallback = _fallbackWaitingOrders.cast<ServiceOrderModel?>().firstWhere(
      (o) => o?.id == orderId,
      orElse: () => null,
    );
    yield fallback;
    yield* _getOrCreateMockController(orderId).stream;
  }

  Stream<ServiceOrderModel?> watchOrder(String orderId) {
    if (SupabaseService.instance.isInitialized) {
      try {
        return SupabaseService.instance.client
            .from(_table)
            .stream(primaryKey: ['id'])
            .eq('id', orderId)
            .map((rows) {
              if (rows.isEmpty) return null;
              return ServiceOrderModel.fromJson(rows.first);
            })
            .handleError((error) {
              debugPrint('Error in watchOrder: $error');
            });
      } catch (e) {
        debugPrint('Error setting up watchOrder: $e');
      }
    }
    return _mockOrderStream(orderId);
  }

  Future<AppResult<ServiceOrderModel>> updateOrderStatus(
    String orderId,
    MoveServiceStatus status,
  ) async {
    try {
      if (SupabaseService.instance.isInitialized) {
        final response = await SupabaseService.instance.client
            .from(_table)
            .update({'status': status.name})
            .eq('id', orderId)
            .select()
            .single();

        final updated = ServiceOrderModel.fromJson(response);
        _mockOrderControllers[orderId]?.add(updated);
        return AppResult.success(updated);
      }
      final idx = _fallbackWaitingOrders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        final updated = _fallbackWaitingOrders[idx].copyWith(status: status);
        _fallbackWaitingOrders[idx] = updated;
        _mockOrderControllers[orderId]?.add(updated);
        return AppResult.success(updated);
      }
      return AppResult.failure('Order not found');
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<ServiceOrderModel>> acceptOrder(
    String orderId,
    String helperId,
  ) async {
    try {
      if (SupabaseService.instance.isInitialized) {
        final response = await SupabaseService.instance.client
            .from(_table)
            .update({
              'helper_id': helperId,
              'status': MoveServiceStatus.accepted.name,
            })
            .eq('id', orderId)
            .eq('status', MoveServiceStatus.waiting.name)
            .select()
            .maybeSingle();

        if (response == null) {
          return AppResult.failure(
            'Pesanan sudah diambil mitra lain atau tidak lagi tersedia.',
          );
        }

        final updated = ServiceOrderModel.fromJson(response);
        _mockOrderControllers[orderId]?.add(updated);
        return AppResult.success(updated);
      }
      final idx = _fallbackWaitingOrders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        final updated = _fallbackWaitingOrders[idx].copyWith(
          helperId: helperId,
          status: MoveServiceStatus.accepted,
        );
        _fallbackWaitingOrders[idx] = updated;
        _mockOrderControllers[orderId]?.add(updated);
        return AppResult.success(updated);
      }
      return AppResult.failure('Order not found');
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<ServiceOrderModel>> completeOrderWithProof(
    String orderId,
    String photoUrl,
    DateTime completedAt,
  ) async {
    try {
      if (SupabaseService.instance.isInitialized) {
        final response = await SupabaseService.instance.client
            .from(_table)
            .update({
              'status': MoveServiceStatus.completed.name,
              'completion_photo_url': photoUrl,
              'completed_at': completedAt.toIso8601String(),
            })
            .eq('id', orderId)
            .select()
            .single();

        final updated = ServiceOrderModel.fromJson(response);
        _mockOrderControllers[orderId]?.add(updated);
        return AppResult.success(updated);
      }
      final idx = _fallbackWaitingOrders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        final updated = _fallbackWaitingOrders[idx].copyWith(
          status: MoveServiceStatus.completed,
          completionPhotoUrl: photoUrl,
          completedAt: completedAt,
        );
        _fallbackWaitingOrders[idx] = updated;
        _mockOrderControllers[orderId]?.add(updated);
        return AppResult.success(updated);
      }
      final fallbackOrder = ServiceOrderModel(
        id: orderId,
        requesterId: 'requester',
        category: ServiceCategory.pindahKos,
        status: MoveServiceStatus.completed,
        locationOrigin: 'Origin',
        locationDestination: 'Destination',
        scheduledAt: DateTime.now(),
        itemDescription: 'Item',
        barterType: BarterType.makanan,
        barterDescription: 'Barter',
        completionPhotoUrl: photoUrl,
        completedAt: completedAt,
        createdAt: DateTime.now(),
      );
      _fallbackWaitingOrders.add(fallbackOrder);
      _mockOrderControllers[orderId]?.add(fallbackOrder);
      return AppResult.success(fallbackOrder);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<ServiceOrderModel>> confirmBarter(String orderId) async {
    try {
      if (SupabaseService.instance.isInitialized) {
        final response = await SupabaseService.instance.client
            .from(_table)
            .update({'barter_confirmed_by_customer': true})
            .eq('id', orderId)
            .select()
            .single();

        final updated = ServiceOrderModel.fromJson(response);
        _mockOrderControllers[orderId]?.add(updated);
        return AppResult.success(updated);
      }
      final idx = _fallbackWaitingOrders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        final updated = _fallbackWaitingOrders[idx].copyWith(
          barterConfirmedByCustomer: true,
        );
        _fallbackWaitingOrders[idx] = updated;
        _mockOrderControllers[orderId]?.add(updated);
        return AppResult.success(updated);
      }
      return AppResult.failure('Order not found');
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  void clearSessionCache() {
    for (final controller in _mockOrderControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _mockOrderControllers.clear();
    _fallbackWaitingOrders.clear();
    _fallbackWaitingOrders.addAll(_defaultWaitingOrders());
  }
}
