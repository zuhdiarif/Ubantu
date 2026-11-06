import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';

class SupabaseMitraService {
  final SupabaseClient? client;

  SupabaseMitraService({this.client});

  bool get isAvailable =>
      client != null || SupabaseService.instance.isInitialized;

  SupabaseClient? get _effectiveClient =>
      client ??
      (SupabaseService.instance.isInitialized
          ? SupabaseService.instance.client
          : null);

  String? get currentUserId =>
      isAvailable ? _effectiveClient?.auth.currentUser?.id : null;

  Future<Map<String, dynamic>?> fetchMitraProfileData(String userId) async {
    if (!isAvailable) return null;
    final activeClient = _effectiveClient;
    if (activeClient == null) return null;
    try {
      final res = await activeClient
          .from('profiles')
          .select(
            'id, full_name, nim, faculty, avatar_url, is_online, mitra_categories, mitra_vehicle_type, mitra_vehicle_plate',
          )
          .eq('id', userId)
          .maybeSingle();
      return res;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchActiveOrder(String userId) async {
    if (!isAvailable) return null;
    final activeClient = _effectiveClient;
    if (activeClient == null) return null;
    try {
      final res = await activeClient
          .from('service_orders')
          .select()
          .eq('helper_id', userId)
          .inFilter('status', [
            MoveServiceStatus.accepted.name,
            MoveServiceStatus.inProgress.name,
          ])
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return res;
    } catch (_) {
      return null;
    }
  }

  Future<AppResult<void>> updateOnlineStatus(String userId, bool isOnline) async {
    if (!isAvailable) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    final activeClient = _effectiveClient;
    if (activeClient == null) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    try {
      await activeClient.from('profiles').update({
        'is_online': isOnline,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      return AppResult.success(null);
    } catch (e) {
      return AppResult.failure('Gagal memperbarui status online: ');
    }
  }

  Future<AppResult<void>> updateMitraRegistration({
    required String userId,
    required List<ServiceCategory> categories,
    String? vehicleType,
    String? vehiclePlate,
  }) async {
    if (!isAvailable) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    final activeClient = _effectiveClient;
    if (activeClient == null) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    try {
      await activeClient.from('profiles').update({
        'mitra_categories': categories.map((c) => c.name).toList(),
        'mitra_vehicle_type': vehicleType,
        'mitra_vehicle_plate': vehiclePlate,
        'role': 'helper',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      return AppResult.success(null);
    } catch (e) {
      return AppResult.failure('Gagal memperbarui data pendaftaran mitra: ');
    }
  }

  Future<AppResult<void>> recordDeclinedOrder({
    required String mitraId,
    required String orderId,
  }) async {
    if (!isAvailable) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    final activeClient = _effectiveClient;
    if (activeClient == null) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    try {
      await activeClient.from('mitra_declined_orders').upsert(
        {
          'mitra_id': mitraId,
          'order_id': orderId,
        },
        onConflict: 'mitra_id,order_id',
      );
      return AppResult.success(null);
    } catch (e) {
      return AppResult.failure('Gagal mencatat penolakan pesanan: ');
    }
  }

  Future<Set<String>> fetchDeclinedOrderIds(String mitraId) async {
    if (!isAvailable) return <String>{};
    final activeClient = _effectiveClient;
    if (activeClient == null) return <String>{};
    try {
      final res = await activeClient
          .from('mitra_declined_orders')
          .select('order_id')
          .eq('mitra_id', mitraId);
      final list = res as List;
      return list
          .map((row) => row['order_id']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }
}
