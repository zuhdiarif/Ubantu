import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_mitra_service.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/mitra_earning_item_model.dart';
import 'package:ubantu/domain/models/mitra_profile_model.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/mitra_repository.dart';
import 'package:ubantu/domain/repositories/session_scoped.dart';

class MitraRepositoryImpl implements IMitraRepository, SessionScoped {
  final SupabaseMitraService _mitraService;
  final Set<String> _declinedOrderIds = {};

  MitraRepositoryImpl({SupabaseMitraService? mitraService})
      : _mitraService = mitraService ?? SupabaseMitraService();

  bool get _useSupabase => _mitraService.isAvailable;

  Set<String> get declinedOrderIdsForTesting =>
      Set.unmodifiable(_declinedOrderIds);

  void seedIncomingOrdersForTesting(List<ServiceOrderModel> orders) {
    _incomingOrders.clear();
    _incomingOrders.addAll(orders);
  }

  ServiceOrderModel? get activeOrderForTesting => _activeOrder;

  void seedActiveOrderForTesting(ServiceOrderModel? order) {
    _activeOrder = order;
  }

  static const _defaultProfile = MitraProfileModel(
    id: 'mitra_user_1',
    userId: 'user_mitra_001',
    name: 'Ahmad Fauzi (Mitra UB)',
    faculty: 'Fakultas Ilmu Komputer, Universitas Brawijaya',
    phone: '081234567890',
    isOnline: true,
    isKtmVerified: true,
    rating: 4.9,
    totalReviews: 38,
    totalOrdersCompleted: 42,
    acceptanceRate: 98.0,
    totalBarterPoints: 180,
    selectedCategories: [
      ServiceCategory.pindahKos,
      ServiceCategory.bersihKos,
      ServiceCategory.antarJemput,
    ],
    vehicleInfo: 'Honda Vario 160 Hitam',
    vehiclePlate: 'N 4821 ABC',
  );

  MitraProfileModel _profile = _defaultProfile;

  static List<ServiceOrderModel> _defaultIncomingOrders() => [
    ServiceOrderModel(
      id: 'ord-mitra-01',
      requesterId: 'req_mahasiswa_1',
      category: ServiceCategory.pindahKos,
      status: MoveServiceStatus.accepted,
      locationOrigin: 'Kos Griya UB, Jl. Watugong No. 12',
      locationDestination: 'Kos Permata, Jl. Sigura-gura IV',
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      itemDescription: '3 Kardus buku, 1 koper pakaian, dan dispenser kecil',
      barterType: BarterType.makanan,
      barterDescription: 'Nasi Padang Ampera + Es Teh Manis',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      helperId: 'mitra_ahmad_fauzi',
    ),
  ];

  final List<ServiceOrderModel> _incomingOrders = _defaultIncomingOrders();

  ServiceOrderModel? _activeOrder;

  final List<ServiceOrderModel> _completedOrders = [];

  static List<MitraEarningItemModel> _defaultEarningsHistory() => [
    MitraEarningItemModel(
      id: 'earn-01',
      orderId: 'ord-past-01',
      orderNumber: 'UB-ORD-8812',
      serviceTitle: 'Bantu Pindah Kos Sigura-gura',
      date: DateTime.now().subtract(const Duration(days: 1)),
      barterDescription: 'Martabak Manis Coklat Keju',
      pointsEarned: 10,
      customerName: 'Bima Aditya (FEB UB)',
    ),
    MitraEarningItemModel(
      id: 'earn-02',
      orderId: 'ord-past-02',
      orderNumber: 'UB-ORD-8794',
      serviceTitle: 'Bersih Kamar Kos Watugong',
      date: DateTime.now().subtract(const Duration(days: 2)),
      barterDescription: 'Kebab Baba Rafi Monster + Jus Mangga',
      pointsEarned: 10,
      customerName: 'Citra Kirana (FIA UB)',
    ),
    MitraEarningItemModel(
      id: 'earn-03',
      orderId: 'ord-past-03',
      orderNumber: 'UB-ORD-8650',
      serviceTitle: 'Tebengan Motor ke UB Dieng',
      date: DateTime.now().subtract(const Duration(days: 4)),
      barterDescription: 'Kopi Kenangan Mantan Large',
      pointsEarned: 10,
      customerName: 'Dhimas Arya (Filkom UB)',
    ),
  ];

  final List<MitraEarningItemModel> _earningsHistory = _defaultEarningsHistory();

  @override
  void clearSessionCache() {
    _profile = _defaultProfile;
    _declinedOrderIds.clear();
    _activeOrder = null;
    _incomingOrders.clear();
    _incomingOrders.addAll(_defaultIncomingOrders());
    _completedOrders.clear();
    _earningsHistory.clear();
    _earningsHistory.addAll(_defaultEarningsHistory());
  }

  @override
  Future<AppResult<MitraProfileModel>> getMitraProfile() async {
    if (_useSupabase) {
      try {
        final currentUserId = _mitraService.currentUserId;
        if (currentUserId != null) {
          final profileData =
              await _mitraService.fetchMitraProfileData(currentUserId);

          var completedCount = _profile.totalOrdersCompleted;
          var totalRev = _profile.totalReviews;
          var avgRating = _profile.rating;

          if (SupabaseService.instance.isInitialized) {
            try {
              final ordersRes = await SupabaseService.instance.client
                  .from('service_orders')
                  .select('id')
                  .eq('helper_id', currentUserId)
                  .eq('status', MoveServiceStatus.completed.name);
              completedCount = (ordersRes as List).length;

              final ratingsRes = await SupabaseService.instance.client
                  .from('ratings')
                  .select('score')
                  .eq('target_user_id', currentUserId);
              final ratingList = (ratingsRes as List);
              totalRev = ratingList.length;
              if (totalRev > 0) {
                final sum = ratingList.fold<double>(
                  0.0,
                  (acc, curr) =>
                      acc + ((curr['score'] as num?)?.toDouble() ?? 5.0),
                );
                avgRating = double.parse((sum / totalRev).toStringAsFixed(1));
              }
            } catch (_) {}
          }

          final authUser = SupabaseService.instance.isInitialized
              ? SupabaseService.instance.client.auth.currentUser
              : null;
          final rawName = profileData?['full_name'] as String? ??
              profileData?['username'] as String? ??
              authUser?.userMetadata?['full_name'] as String? ??
              authUser?.email?.split('@').first ??
              _profile.name;
          final realName = rawName.contains('(Mitra UB)')
              ? rawName
              : '$rawName (Mitra UB)';
          final realFaculty = profileData?['faculty'] as String? ??
              _profile.faculty;
          final realPhone = profileData?['phone_number'] as String? ??
              authUser?.phone ??
              _profile.phone;
          final realPoints = (profileData?['barter_points'] as num?)?.toInt() ??
              (completedCount * 10);

          List<ServiceCategory> parsedCategories = _profile.selectedCategories;
          if (profileData?['mitra_categories'] != null) {
            final catList = (profileData!['mitra_categories'] as List)
                .map((e) => e.toString())
                .toList();
            final matched = catList
                .map((name) {
                  for (final cat in ServiceCategory.values) {
                    if (cat.name == name) return cat;
                  }
                  return null;
                })
                .whereType<ServiceCategory>()
                .toList();
            if (matched.isNotEmpty) {
              parsedCategories = matched;
            }
          }

          _profile = _profile.copyWith(
            id: currentUserId,
            userId: currentUserId,
            name: realName,
            faculty: realFaculty,
            phone: realPhone,
            avatarUrl: profileData?['avatar_url'] as String? ?? _profile.avatarUrl,
            isOnline: profileData?['is_online'] as bool? ?? _profile.isOnline,
            selectedCategories: parsedCategories,
            vehicleInfo: profileData?['mitra_vehicle_type'] as String? ??
                _profile.vehicleInfo,
            vehiclePlate: profileData?['mitra_vehicle_plate'] as String? ??
                _profile.vehiclePlate,
            totalOrdersCompleted: completedCount,
            totalReviews: totalRev,
            rating: totalRev > 0 ? avgRating : 5.0,
            totalBarterPoints: realPoints,
          );
        }
      } catch (_) {}
    }
    return AppResult.success(_profile);
  }

  @override
  Future<AppResult<bool>> toggleOnlineStatus(bool isOnline) async {
    if (_useSupabase) {
      final currentUserId = _mitraService.currentUserId;
      if (currentUserId != null) {
        final res = await _mitraService.updateOnlineStatus(currentUserId, isOnline);
        if (!res.isSuccess) {
          return AppResult.failure(res.errorMessage ?? 'Gagal memperbarui status online');
        }
      }
    }
    _profile = _profile.copyWith(isOnline: isOnline);
    return AppResult.success(_profile.isOnline);
  }

  Future<AppResult<bool>> registerMitraCategories(
    List<ServiceCategory> categories, {
    String? vehicleType,
    String? vehiclePlate,
  }) async {
    if (_useSupabase) {
      final currentUserId = _mitraService.currentUserId;
      if (currentUserId != null) {
        final res = await _mitraService.updateMitraRegistration(
          userId: currentUserId,
          categories: categories,
          vehicleType: vehicleType ?? _profile.vehicleInfo,
          vehiclePlate: vehiclePlate ?? _profile.vehiclePlate,
        );
        if (!res.isSuccess) {
          return AppResult.failure(res.errorMessage ?? 'Gagal memperbarui data pendaftaran mitra');
        }
      }
    }
    _profile = _profile.copyWith(
      selectedCategories: categories,
      vehicleInfo: vehicleType ?? _profile.vehicleInfo,
      vehiclePlate: vehiclePlate ?? _profile.vehiclePlate,
    );
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> updateServiceCategories(
    List<ServiceCategory> categories,
  ) async {
    return registerMitraCategories(categories);
  }

  @override
  Future<AppResult<List<ServiceOrderModel>>> getIncomingOrders() async {
    if (_useSupabase) {
      final currentUserId = _mitraService.currentUserId;
      if (currentUserId != null) {
        try {
          final remoteDeclined =
              await _mitraService.fetchDeclinedOrderIds(currentUserId);
          _declinedOrderIds.addAll(remoteDeclined);
        } catch (_) {}
      }
    }

    if (_useSupabase && SupabaseService.instance.isInitialized) {
      try {
        final currentUserId = _mitraService.currentUserId;
        final response = await SupabaseService.instance.client
            .from('service_orders')
            .select()
            .eq('status', MoveServiceStatus.waiting.name)
            .order('created_at', ascending: false);

        final List<ServiceOrderModel> remoteOrders = (response as List)
            .map((e) => ServiceOrderModel.fromJson(e as Map<String, dynamic>))
            .where((order) {
              if (currentUserId != null && order.requesterId == currentUserId) {
                return false;
              }
              if (_declinedOrderIds.contains(order.id)) {
                return false;
              }
              if (_profile.selectedCategories.isNotEmpty &&
                  !_profile.selectedCategories.contains(order.category)) {
                return false;
              }
              return true;
            })
            .toList();

        _incomingOrders.clear();
        _incomingOrders.addAll(remoteOrders);
        return AppResult.success(List.unmodifiable(_incomingOrders));
      } catch (e) {
        return AppResult.failure('Gagal memuat pesanan masuk: $e');
      }
    }

    final localFiltered = _incomingOrders
        .where((order) => !_declinedOrderIds.contains(order.id))
        .toList();
    return AppResult.success(List.unmodifiable(localFiltered));
  }

  @override
  Future<AppResult<ServiceOrderModel?>> getActiveOrder() async {
    if (_useSupabase) {
      try {
        final currentUserId = _mitraService.currentUserId;
        if (currentUserId != null) {
          final res = await _mitraService.fetchActiveOrder(currentUserId);
          if (res != null) {
            _activeOrder = ServiceOrderModel.fromJson(res);
          } else {
            _activeOrder = null;
          }
        }
      } catch (_) {}
    } else if (SupabaseService.instance.isInitialized) {
      try {
        final currentUserId =
            SupabaseService.instance.client.auth.currentUser?.id;
        if (currentUserId != null) {
          final res = await SupabaseService.instance.client
              .from('service_orders')
              .select()
              .eq('helper_id', currentUserId)
              .inFilter('status', [
                MoveServiceStatus.accepted.name,
                MoveServiceStatus.inProgress.name,
              ])
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

          if (res != null) {
            _activeOrder = ServiceOrderModel.fromJson(res);
          } else {
            _activeOrder = null;
          }
        }
      } catch (_) {}
    }
    return AppResult.success(_activeOrder);
  }

  @override
  Future<AppResult<List<ServiceOrderModel>>> getCompletedOrders() async {
    if (SupabaseService.instance.isInitialized) {
      try {
        final currentUserId =
            SupabaseService.instance.client.auth.currentUser?.id;
        if (currentUserId != null) {
          final res = await SupabaseService.instance.client
              .from('service_orders')
              .select()
              .eq('helper_id', currentUserId)
              .eq('status', MoveServiceStatus.completed.name)
              .order('created_at', ascending: false);

          final List<ServiceOrderModel> completed = (res as List)
              .map((e) => ServiceOrderModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _completedOrders.clear();
          _completedOrders.addAll(completed);
          return AppResult.success(List.unmodifiable(_completedOrders));
        }
      } catch (e) {
        return AppResult.failure('Gagal memuat riwayat pesanan: $e');
      }
    }
    return AppResult.success(List.unmodifiable(_completedOrders));
  }

  @override
  Future<AppResult<List<MitraEarningItemModel>>> getEarningsHistory() async {
    if (SupabaseService.instance.isInitialized) {
      try {
        final currentUserId =
            SupabaseService.instance.client.auth.currentUser?.id;
        if (currentUserId != null) {
          final res = await SupabaseService.instance.client
              .from('service_orders')
              .select()
              .eq('helper_id', currentUserId)
              .eq('status', MoveServiceStatus.completed.name)
              .order('created_at', ascending: false);

          final items = (res as List).map((row) {
            final order =
                ServiceOrderModel.fromJson(row as Map<String, dynamic>);
            return MitraEarningItemModel(
              id: 'earn-${order.id}',
              orderId: order.id,
              orderNumber:
                  'UB-ORD-${order.id.length > 4 ? order.id.substring(0, 4).toUpperCase() : order.id}',
              serviceTitle: 'Layanan ${_categoryTitle(order.category)}',
              date: order.createdAt,
              barterDescription: order.barterDescription,
              pointsEarned: 10,
              customerName: 'Mahasiswa UB',
            );
          }).toList();
          _earningsHistory.clear();
          _earningsHistory.addAll(items);
          return AppResult.success(List.unmodifiable(_earningsHistory));
        }
      } catch (e) {
        return AppResult.failure('Gagal memuat riwayat penghasilan: $e');
      }
    }
    return AppResult.success(List.unmodifiable(_earningsHistory));
  }

  @override
  Future<AppResult<bool>> acceptOrder(String orderId) async {
    if (_useSupabase) {
      final currentUserId = _mitraService.currentUserId ?? _profile.id;
      final res = await _mitraService.acceptOrder(
        orderId: orderId,
        helperId: currentUserId,
      );
      if (!res.isSuccess || res.data == null) {
        return AppResult.failure(res.errorMessage ?? 'Gagal mengambil pesanan.');
      }
      _activeOrder = res.data;
      _incomingOrders.removeWhere((o) => o.id == orderId);
      return AppResult.success(true);
    }

    ServiceOrderModel? selected;
    final index = _incomingOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      selected = _incomingOrders[index];
    }

    if (selected != null) {
      final updated = selected.copyWith(
        status: MoveServiceStatus.accepted,
        helperId: _profile.id,
      );
      _activeOrder = updated;
      _incomingOrders.removeWhere((o) => o.id == updated.id);
      return AppResult.success(true);
    }

    final dummy = ServiceOrderModel(
      id: orderId,
      requesterId: 'req_mahasiswa_accepted',
      category: ServiceCategory.bersihKos,
      status: MoveServiceStatus.accepted,
      locationOrigin: 'Kos Mahasiswa UB',
      locationDestination: 'Kos Mahasiswa UB',
      scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      itemDescription: 'Bantuan diterima',
      barterType: BarterType.makanan,
      barterDescription: 'Sesuai kesepakatan',
      createdAt: DateTime.now(),
      helperId: _profile.id,
    );
    _activeOrder = dummy;
    _incomingOrders.removeWhere((o) => o.id == orderId);
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> declineOrder(String orderId) async {
    if (_useSupabase) {
      final currentUserId = _mitraService.currentUserId;
      if (currentUserId != null) {
        final res = await _mitraService.recordDeclinedOrder(
          mitraId: currentUserId,
          orderId: orderId,
        );
        if (!res.isSuccess) {
          return AppResult.failure(res.errorMessage ?? 'Gagal mencatat penolakan pesanan');
        }
      }
    }
    _declinedOrderIds.add(orderId);
    _incomingOrders.removeWhere((o) => o.id == orderId);
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> updateOrderStatus(
    String orderId,
    MoveServiceStatus status,
  ) async {
    final target = (_activeOrder != null && _activeOrder!.id == orderId)
        ? _activeOrder
        : _incomingOrders.cast<ServiceOrderModel?>().firstWhere(
              (o) => o?.id == orderId,
              orElse: () => null,
            ) ??
            _activeOrder;
    if (target == null) {
      return AppResult.failure('Order aktif tidak cocok');
    }

    if (_useSupabase) {
      final res = await _mitraService.updateOrderStatus(
        orderId: orderId,
        status: status,
      );
      if (!res.isSuccess) {
        return AppResult.failure(res.errorMessage ?? 'Gagal memperbarui status pesanan.');
      }
    }

    if (status == MoveServiceStatus.completed) {
      final finished = target.copyWith(status: status);
      _completedOrders.insert(0, finished);

      final newEarning = MitraEarningItemModel(
        id: 'earn-${DateTime.now().millisecondsSinceEpoch}',
        orderId: finished.id,
        orderNumber:
            'UB-ORD-${finished.id.length > 4 ? finished.id.substring(0, 4).toUpperCase() : "9901"}',
        serviceTitle: 'Layanan ${_categoryTitle(finished.category)}',
        date: DateTime.now(),
        barterDescription: finished.barterDescription,
        pointsEarned: 10,
        customerName: 'Mahasiswa UB',
      );
      _earningsHistory.insert(0, newEarning);

      _profile = _profile.copyWith(
        totalOrdersCompleted: _profile.totalOrdersCompleted + 1,
        totalBarterPoints: _profile.totalBarterPoints + 10,
      );

      _activeOrder = null;
      _incomingOrders.removeWhere((o) => o.id == orderId);
    } else {
      _activeOrder = target.copyWith(status: status);
      final idx = _incomingOrders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        _incomingOrders[idx] = _activeOrder!;
      }
    }

    return AppResult.success(true);
  }

  String _categoryTitle(ServiceCategory cat) {
    switch (cat) {
      case ServiceCategory.pindahKos:
        return 'Pindah Kos';
      case ServiceCategory.bersihKos:
        return 'Bersih Kos';
      case ServiceCategory.antarJemput:
        return 'Antar Jemput';
    }
  }
}
