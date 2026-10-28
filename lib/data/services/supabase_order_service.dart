import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';

class SupabaseOrderService {
  static const String _table = 'service_orders';

  final List<ServiceOrderModel> _fallbackWaitingOrders = [
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
    } catch (_) {
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

      try {
        final response = await SupabaseService.instance.client
            .from(_table)
            .insert(data)
            .select()
            .single();

        return AppResult.success(
          ServiceOrderModel.fromJson(response),
        );
      } catch (insertError) {
        final errorStr = insertError.toString().toLowerCase();
        if (errorStr.contains('is_female_only') || errorStr.contains('pgrst204')) {
          final fallbackData = Map<String, dynamic>.from(data)
            ..remove('is_female_only');
          final response = await SupabaseService.instance.client
              .from(_table)
              .insert(fallbackData)
              .select()
              .single();

          return AppResult.success(
            ServiceOrderModel.fromJson(response),
          );
        }
        rethrow;
      }
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<ServiceOrderModel>> updateOrderStatus(
    String orderId,
    MoveServiceStatus status,
  ) async {
    try {
      final response = await SupabaseService.instance.client
          .from(_table)
          .update({'status': status.name})
          .eq('id', orderId)
          .select()
          .single();

      return AppResult.success(
        ServiceOrderModel.fromJson(response),
      );
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  Future<AppResult<ServiceOrderModel>> acceptOrder(
    String orderId,
    String helperId,
  ) async {
    try {
      final response = await SupabaseService.instance.client
          .from(_table)
          .update({
            'helper_id': helperId,
            'status': MoveServiceStatus.accepted.name,
          })
          .eq('id', orderId)
          .select()
          .single();

      return AppResult.success(
        ServiceOrderModel.fromJson(response),
      );
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }
}
