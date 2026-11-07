import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/service_order_model.dart';

class SupabaseOrderService {
  static const String _table = 'service_orders';

  bool get isAvailable => SupabaseService.instance.isInitialized;

  static List<ServiceOrderModel> _defaultWaitingOrders() => [
    ServiceOrderModel(
      id: 'ord-mitra-01',
      requesterId: 'req_mahasiswa_1',
      requesterName: 'Bima Aditya (FEB UB)',
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
      requesterName: 'Citra Kirana (FIA UB)',
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
      requesterName: 'Dhimas Arya (Filkom UB)',
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

  Future<AppResult<List<ServiceOrderModel>>> getActiveOrders({
    String? excludeRequesterId,
  }) async {
    final currentUserId = excludeRequesterId ??
        (SupabaseService.instance.isInitialized
            ? SupabaseService.instance.client.auth.currentUser?.id
            : null);

    try {
      if (SupabaseService.instance.isInitialized) {
        var query = SupabaseService.instance.client
            .from(_table)
            .select()
            .eq('status', MoveServiceStatus.waiting.name);

        if (currentUserId != null && currentUserId.isNotEmpty) {
          query = query.neq('requester_id', currentUserId);
        }

        final response = await query.order('created_at', ascending: false);
        final rawRows = (response as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        final enrichedRows = await _enrichRequesterNames(rawRows);
        final orders = enrichedRows
            .map((e) => ServiceOrderModel.fromJson(e))
            .where((o) {
              if (currentUserId != null && currentUserId.isNotEmpty) {
                return o.requesterId != currentUserId;
              }
              return true;
            })
            .toList();
        return AppResult.success(orders);
      }
      final fallbackFiltered = _fallbackWaitingOrders.where((o) {
        if (currentUserId != null && currentUserId.isNotEmpty) {
          return o.requesterId != currentUserId;
        }
        return true;
      }).toList();
      return AppResult.success(List.from(fallbackFiltered));
    } catch (e) {
      if (SupabaseService.instance.isInitialized) {
        return AppResult.failure('Gagal memuat pesanan aktif: $e');
      }
      final fallbackFiltered = _fallbackWaitingOrders.where((o) {
        if (currentUserId != null && currentUserId.isNotEmpty) {
          return o.requesterId != currentUserId;
        }
        return true;
      }).toList();
      return AppResult.success(List.from(fallbackFiltered));
    }
  }

  Future<AppResult<List<ServiceOrderModel>>> getOrderHistory(
    String userId,
  ) async {
    try {
      if (!SupabaseService.instance.isInitialized) {
        final list = _fallbackWaitingOrders
            .where((o) => o.requesterId == userId || o.helperId == userId || userId.isEmpty)
            .toList();
        return AppResult.success(list);
      }
      final response = await SupabaseService.instance.client
          .from(_table)
          .select()
          .or('requester_id.eq.$userId,helper_id.eq.$userId')
          .order('created_at', ascending: false);

      final rawRows = (response as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final enrichedRows = await _enrichRequesterNames(rawRows);
      final orders = enrichedRows
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
      if (!SupabaseService.instance.isInitialized) {
        final fallbackOrder = order.copyWith(
          id: order.id.isNotEmpty
              ? order.id
              : 'local_${DateTime.now().millisecondsSinceEpoch}',
          createdAt: order.createdAt,
        );
        _fallbackWaitingOrders.insert(0, fallbackOrder);
        return AppResult.success(fallbackOrder);
      }
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
    if (helperId.trim().isEmpty) {
      return AppResult.failure('ID mitra tidak valid.');
    }

    try {
      if (SupabaseService.instance.isInitialized) {
        String? helperName;
        try {
          final profileRes = await SupabaseService.instance.client
              .from('profiles')
              .select('full_name')
              .eq('id', helperId)
              .maybeSingle();
          if (profileRes != null && profileRes['full_name'] != null) {
            final name = profileRes['full_name'].toString().trim();
            if (name.isNotEmpty) {
              helperName = name;
            }
          }
        } catch (_) {}

        final updateData = <String, dynamic>{
          'helper_id': helperId,
          'status': MoveServiceStatus.accepted.name,
          if (helperName != null && helperName.isNotEmpty)
            'helper_name': helperName,
        };

        final response = await SupabaseService.instance.client
            .from(_table)
            .update(updateData)
            .eq('id', orderId)
            .eq('status', MoveServiceStatus.waiting.name)
            .neq('requester_id', helperId)
            .select()
            .maybeSingle();

        if (response == null) {
          return AppResult.failure(
            'Pesanan tidak dapat diambil (milik sendiri atau sudah diambil mitra lain).',
          );
        }

        final enrichedList = await _enrichRequesterNames([Map<String, dynamic>.from(response)]);
        final updated = ServiceOrderModel.fromJson(enrichedList.first);
        _mockOrderControllers[orderId]?.add(updated);
        return AppResult.success(updated);
      }
      final idx = _fallbackWaitingOrders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        if (_fallbackWaitingOrders[idx].requesterId == helperId) {
          return AppResult.failure('Tidak dapat mengambil pesanan milik sendiri.');
        }
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

  Future<List<Map<String, dynamic>>> _enrichRequesterNames(
    List<Map<String, dynamic>> rows,
  ) async {
    final ids = <String>{};
    for (final row in rows) {
      final rName = row['requester_name']?.toString();
      final rId = row['requester_id']?.toString();
      if ((rName == null || rName.trim().isEmpty) &&
          rId != null &&
          rId.trim().isNotEmpty) {
        ids.add(rId);
      }
      final hName = row['helper_name']?.toString();
      final hId = row['helper_id']?.toString();
      if ((hName == null || hName.trim().isEmpty) &&
          hId != null &&
          hId.trim().isNotEmpty) {
        ids.add(hId);
      }
    }

    if (ids.isEmpty || !SupabaseService.instance.isInitialized) {
      return rows;
    }

    try {
      final profilesRes = await SupabaseService.instance.client
          .from('profiles')
          .select('id, full_name')
          .inFilter('id', ids.toList());

      final Map<String, String> nameById = {};
      for (final p in profilesRes as List<dynamic>) {
        if (p is Map && p['id'] != null && p['full_name'] != null) {
          final fullName = p['full_name'].toString().trim();
          if (fullName.isNotEmpty) {
            nameById[p['id'].toString()] = fullName;
          }
        }
      }

      final enrichedList = <Map<String, dynamic>>[];
      for (final row in rows) {
        final enriched = Map<String, dynamic>.from(row);
        final rName = enriched['requester_name']?.toString();
        final rId = enriched['requester_id']?.toString();
        if ((rName == null || rName.trim().isEmpty) &&
            rId != null &&
            nameById.containsKey(rId)) {
          enriched['requester_name'] = nameById[rId];
        }

        final hName = enriched['helper_name']?.toString();
        final hId = enriched['helper_id']?.toString();
        if ((hName == null || hName.trim().isEmpty) &&
            hId != null &&
            nameById.containsKey(hId)) {
          enriched['helper_name'] = nameById[hId];
        }
        enrichedList.add(enriched);
      }
      return enrichedList;
    } catch (_) {
      return rows;
    }
  }

  Future<AppResult<void>> updateOrderNegotiation(
    String orderId, {
    required PaymentMethodType paymentMethod,
    required int price,
    String? barterDescription,
  }) async {
    try {
      if (!SupabaseService.instance.isInitialized) {
        final idx = _fallbackWaitingOrders.indexWhere((o) => o.id == orderId);
        if (idx != -1) {
          _fallbackWaitingOrders[idx] = _fallbackWaitingOrders[idx].copyWith(
            barterDescription: barterDescription ?? _fallbackWaitingOrders[idx].barterDescription,
            barterConfirmedByCustomer: false,
          );
        }
        return AppResult.success(null);
      }
      await SupabaseService.instance.client.from(_table).update({
        'payment_method': paymentMethod.name,
        'price': price,
        'barter_description': barterDescription,
        'is_barter_confirmed': false,
      }).eq('id', orderId);
      return AppResult.success(null);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<ServiceOrderModel>> fetchOrderById(String orderId) async {
    try {
      if (!SupabaseService.instance.isInitialized) {
        final found = _fallbackWaitingOrders.cast<ServiceOrderModel?>().firstWhere(
              (o) => o?.id == orderId,
              orElse: () => null,
            );
        if (found != null) {
          return AppResult.success(found);
        }
        return AppResult.failure('Pesanan tidak ditemukan');
      }
      final data = await SupabaseService.instance.client
          .from(_table)
          .select()
          .eq('id', orderId)
          .maybeSingle();
      if (data == null) {
        return AppResult.failure('Pesanan tidak ditemukan');
      }
      final enriched = await _enrichRequesterNames([Map<String, dynamic>.from(data)]);
      return AppResult.success(ServiceOrderModel.fromJson(enriched.first));
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
