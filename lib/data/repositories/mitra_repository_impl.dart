import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/mitra_earning_item_model.dart';
import 'package:ubantu/domain/models/mitra_profile_model.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/mitra_repository.dart';

class MitraRepositoryImpl implements IMitraRepository {
  MitraProfileModel _profile = const MitraProfileModel(
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

  final List<ServiceOrderModel> _incomingOrders = [
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

  ServiceOrderModel? _activeOrder;

  final List<ServiceOrderModel> _completedOrders = [];

  final List<MitraEarningItemModel> _earningsHistory = [
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

  @override
  Future<AppResult<MitraProfileModel>> getMitraProfile() async {
    return AppResult.success(_profile);
  }

  @override
  Future<AppResult<bool>> toggleOnlineStatus(bool isOnline) async {
    _profile = _profile.copyWith(isOnline: isOnline);
    return AppResult.success(_profile.isOnline);
  }

  @override
  Future<AppResult<bool>> updateServiceCategories(
    List<ServiceCategory> categories,
  ) async {
    _profile = _profile.copyWith(selectedCategories: categories);
    return AppResult.success(true);
  }

  @override
  Future<AppResult<List<ServiceOrderModel>>> getIncomingOrders() async {
    if (SupabaseService.instance.isInitialized) {
      try {
        final currentUserId =
            SupabaseService.instance.client.auth.currentUser?.id ?? _profile.id;
        final response = await SupabaseService.instance.client
            .from('service_orders')
            .select()
            .eq('helper_id', currentUserId)
            .inFilter('status', [
              MoveServiceStatus.accepted.name,
              MoveServiceStatus.inProgress.name,
            ])
            .order('created_at', ascending: false);

        final List<ServiceOrderModel> remoteOrders = (response as List)
            .map((e) => ServiceOrderModel.fromJson(e as Map<String, dynamic>))
            .toList();

        _incomingOrders.clear();
        _incomingOrders.addAll(remoteOrders);
        if (_activeOrder != null &&
            (_activeOrder!.status == MoveServiceStatus.accepted ||
                _activeOrder!.status == MoveServiceStatus.inProgress)) {
          if (!_incomingOrders.any((o) => o.id == _activeOrder!.id)) {
            _incomingOrders.insert(0, _activeOrder!);
          }
        }
      } catch (_) {}
    }
    return AppResult.success(List.unmodifiable(_incomingOrders));
  }

  @override
  Future<AppResult<ServiceOrderModel?>> getActiveOrder() async {
    return AppResult.success(_activeOrder);
  }

  @override
  Future<AppResult<List<ServiceOrderModel>>> getCompletedOrders() async {
    return AppResult.success(List.unmodifiable(_completedOrders));
  }

  @override
  Future<AppResult<List<MitraEarningItemModel>>> getEarningsHistory() async {
    return AppResult.success(List.unmodifiable(_earningsHistory));
  }

  @override
  Future<AppResult<bool>> acceptOrder(String orderId) async {
    ServiceOrderModel? selected;
    final index = _incomingOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      selected = _incomingOrders[index];
    }

    if (SupabaseService.instance.isInitialized) {
      try {
        final currentUserId =
            SupabaseService.instance.client.auth.currentUser?.id ?? _profile.id;
        final res = await SupabaseService.instance.client
            .from('service_orders')
            .update({
              'helper_id': currentUserId,
              'status': MoveServiceStatus.accepted.name,
            })
            .eq('id', orderId)
            .select()
            .single();
        selected = ServiceOrderModel.fromJson(res);
      } catch (_) {}
    }

    if (selected != null) {
      final updated = selected.copyWith(
        status: MoveServiceStatus.accepted,
        helperId: _profile.id,
      );
      _activeOrder = updated;
      final existingIdx = _incomingOrders.indexWhere((o) => o.id == updated.id);
      if (existingIdx != -1) {
        _incomingOrders[existingIdx] = updated;
      } else {
        _incomingOrders.insert(0, updated);
      }
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
    _incomingOrders.insert(0, dummy);
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> declineOrder(String orderId) async {
    _incomingOrders.removeWhere((o) => o.id == orderId);
    return AppResult.success(true);
  }

  @override
  Future<AppResult<bool>> updateOrderStatus(
    String orderId,
    MoveServiceStatus status,
  ) async {
    if (_activeOrder != null && _activeOrder!.id == orderId) {
      if (status == MoveServiceStatus.completed) {
        final finished = _activeOrder!.copyWith(status: status);
        _completedOrders.insert(0, finished);

        final newEarning = MitraEarningItemModel(
          id: 'earn-${DateTime.now().millisecondsSinceEpoch}',
          orderId: finished.id,
          orderNumber:
              'UB-ORD-${finished.id.length > 4 ? finished.id.substring(0, 4).toUpperCase() : '9901'}',
          serviceTitle: 'Layanan ${finished.category.name}',
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
        _activeOrder = _activeOrder!.copyWith(status: status);
        final idx = _incomingOrders.indexWhere((o) => o.id == orderId);
        if (idx != -1) {
          _incomingOrders[idx] = _activeOrder!;
        }
      }

      if (SupabaseService.instance.isInitialized) {
        try {
          await SupabaseService.instance.client
              .from('service_orders')
              .update({'status': status.name})
              .eq('id', orderId);
        } catch (_) {}
      }

      return AppResult.success(true);
    }
    return AppResult.failure('Order aktif tidak cocok');
  }
}
