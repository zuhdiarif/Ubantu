import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/mitra_earning_item_model.dart';
import 'package:ubantu/data/models/mitra_profile_model.dart';
import 'package:ubantu/data/models/service_order_model.dart';

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

  Future<Map<String, dynamic>> fetchMitraStats(String userId) async {
    if (!isAvailable) return {};
    final activeClient = _effectiveClient;
    if (activeClient == null) return {};
    try {
      final ordersRes = await activeClient
          .from('service_orders')
          .select('id')
          .eq('helper_id', userId)
          .eq('status', MoveServiceStatus.completed.name);
      final completedCount = (ordersRes as List).length;

      final ratingsRes = await activeClient
          .from('ratings')
          .select('score')
          .eq('target_user_id', userId);
      final ratingList = (ratingsRes as List);
      final totalRev = ratingList.length;
      var avgRating = 5.0;
      if (totalRev > 0) {
        final sum = ratingList.fold<double>(
          0.0,
          (acc, curr) => acc + ((curr['score'] as num?)?.toDouble() ?? 5.0),
        );
        avgRating = double.parse((sum / totalRev).toStringAsFixed(1));
      }
      return {
        'completedCount': completedCount,
        'totalRev': totalRev,
        'avgRating': avgRating,
      };
    } catch (_) {
      return {};
    }
  }

  Future<AppResult<MitraProfileModel>> fetchMitraProfile(
    String userId,
    MitraProfileModel fallbackProfile,
  ) async {
    if (!isAvailable) {
      return AppResult.success(fallbackProfile);
    }
    try {
      final profileData = await fetchMitraProfileData(userId);
      if (profileData == null && _effectiveClient == null) {
        return AppResult.success(fallbackProfile);
      }
      final stats = await fetchMitraStats(userId);

      final completedCount =
          (stats['completedCount'] as int?) ?? fallbackProfile.totalOrdersCompleted;
      final totalRev = (stats['totalRev'] as int?) ?? fallbackProfile.totalReviews;
      final avgRating = (stats['avgRating'] as double?) ?? fallbackProfile.rating;

      final authUser = _effectiveClient?.auth.currentUser;
      final rawName = profileData?['full_name'] as String? ??
          profileData?['username'] as String? ??
          authUser?.userMetadata?['full_name'] as String? ??
          authUser?.email?.split('@').first ??
          fallbackProfile.name;
      final realName = rawName.contains('(Mitra UB)')
          ? rawName
          : '$rawName (Mitra UB)';
      final realFaculty =
          profileData?['faculty'] as String? ?? fallbackProfile.faculty;
      final realPhone = profileData?['phone_number'] as String? ??
          authUser?.phone ??
          fallbackProfile.phone;
      final realPoints = (profileData?['barter_points'] as num?)?.toInt() ??
          (completedCount * 10);

      List<ServiceCategory> parsedCategories = fallbackProfile.selectedCategories;
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

      final profile = fallbackProfile.copyWith(
        id: userId,
        userId: userId,
        name: realName,
        faculty: realFaculty,
        phone: realPhone,
        avatarUrl:
            profileData?['avatar_url'] as String? ?? fallbackProfile.avatarUrl,
        isOnline:
            profileData?['is_online'] as bool? ?? fallbackProfile.isOnline,
        selectedCategories: parsedCategories,
        vehicleInfo: profileData?['mitra_vehicle_type'] as String? ??
            fallbackProfile.vehicleInfo,
        vehiclePlate: profileData?['mitra_vehicle_plate'] as String? ??
            fallbackProfile.vehiclePlate,
        totalOrdersCompleted: completedCount,
        totalReviews: totalRev,
        rating: totalRev > 0 ? avgRating : 5.0,
        totalBarterPoints: realPoints,
      );

      return AppResult.success(profile);
    } catch (e) {
      return AppResult.failure('Gagal memuat profil mitra: $e');
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
      return AppResult.failure('Gagal memperbarui status online: $e');
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
      return AppResult.failure('Gagal memperbarui data pendaftaran mitra: $e');
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
      return AppResult.failure('Gagal mencatat penolakan pesanan: $e');
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

  Future<AppResult<List<ServiceOrderModel>>> fetchIncomingOrders({
    required String? currentUserId,
    Set<String> declinedOrderIds = const {},
    List<ServiceCategory> filterCategories = const [],
  }) async {
    if (!isAvailable) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    final activeClient = _effectiveClient;
    if (activeClient == null) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    try {
      final response = await activeClient
          .from('service_orders')
          .select()
          .eq('status', MoveServiceStatus.waiting.name)
          .order('created_at', ascending: false);

      final rows = (response as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((row) {
            final reqId = row['requester_id']?.toString();
            if (currentUserId != null && reqId == currentUserId) {
              return false;
            }
            final orderId = row['id']?.toString();
            if (orderId != null && declinedOrderIds.contains(orderId)) {
              return false;
            }
            return true;
          })
          .toList();

      final missingRequesterIds = rows
          .where((r) {
            final rName = r['requester_name']?.toString();
            final rId = r['requester_id']?.toString();
            return (rName == null || rName.trim().isEmpty) &&
                (rId != null && rId.trim().isNotEmpty);
          })
          .map((r) => r['requester_id'].toString())
          .toSet();

      if (missingRequesterIds.isNotEmpty) {
        try {
          final profilesRes = await activeClient
              .from('profiles')
              .select('id, full_name')
              .inFilter('id', missingRequesterIds.toList());
          final Map<String, String> nameMap = {};
          for (final p in profilesRes as List<dynamic>) {
            if (p is Map && p['id'] != null && p['full_name'] != null) {
              final fullName = p['full_name'].toString().trim();
              if (fullName.isNotEmpty) {
                nameMap[p['id'].toString()] = fullName;
              }
            }
          }
          for (final row in rows) {
            final rName = row['requester_name']?.toString();
            final rId = row['requester_id']?.toString();
            if ((rName == null || rName.trim().isEmpty) &&
                rId != null &&
                nameMap.containsKey(rId)) {
              row['requester_name'] = nameMap[rId];
            }
          }
        } catch (_) {}
      }

      final List<ServiceOrderModel> remoteOrders = rows
          .map((e) => ServiceOrderModel.fromJson(e))
          .where((order) {
            if (filterCategories.isNotEmpty &&
                !filterCategories.contains(order.category)) {
              return false;
            }
            return true;
          })
          .toList();

      return AppResult.success(remoteOrders);
    } catch (e) {
      return AppResult.failure('Gagal memuat pesanan masuk: $e');
    }
  }

  Future<AppResult<List<ServiceOrderModel>>> fetchCompletedOrders(String userId) async {
    if (!isAvailable) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    final activeClient = _effectiveClient;
    if (activeClient == null) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    try {
      final res = await activeClient
          .from('service_orders')
          .select()
          .eq('helper_id', userId)
          .eq('status', MoveServiceStatus.completed.name)
          .order('created_at', ascending: false);

      final List<ServiceOrderModel> completed = (res as List)
          .map((e) => ServiceOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return AppResult.success(completed);
    } catch (e) {
      return AppResult.failure('Gagal memuat riwayat pesanan: $e');
    }
  }

  Future<AppResult<List<MitraEarningItemModel>>> fetchEarningsHistory(String userId) async {
    if (!isAvailable) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    final activeClient = _effectiveClient;
    if (activeClient == null) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    try {
      final res = await activeClient
          .from('service_orders')
          .select()
          .eq('helper_id', userId)
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
          customerName: (order.requesterName != null && order.requesterName!.isNotEmpty)
              ? order.requesterName!
              : 'Mahasiswa UB',
        );
      }).toList();
      return AppResult.success(items);
    } catch (e) {
      return AppResult.failure('Gagal memuat riwayat penghasilan: $e');
    }
  }

  String _categoryTitle(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.pindahKos:
        return 'Pindah Kos';
      case ServiceCategory.bersihKos:
        return 'Bersih Kos';
      case ServiceCategory.antarJemput:
        return 'Antar Jemput';
    }
  }

  Future<AppResult<ServiceOrderModel>> acceptOrder({
    required String orderId,
    required String helperId,
    String? requesterId,
  }) async {
    if (requesterId != null && requesterId.isNotEmpty && requesterId == helperId) {
      return AppResult.failure('Tidak dapat mengambil pesanan milik sendiri.');
    }
    if (!isAvailable) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    final activeClient = _effectiveClient;
    if (activeClient == null) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    try {
      final res = await activeClient
          .from('service_orders')
          .update({
            'helper_id': helperId,
            'status': MoveServiceStatus.accepted.name,
          })
          .eq('id', orderId)
          .eq('status', MoveServiceStatus.waiting.name)
          .neq('requester_id', helperId)
          .select()
          .maybeSingle();
      if (res == null) {
        return AppResult.failure(
          'Pesanan tidak dapat diambil (milik sendiri atau sudah diambil mitra lain).',
        );
      }
      return AppResult.success(ServiceOrderModel.fromJson(res));
    } catch (e) {
      return AppResult.failure('Gagal mengambil pesanan: $e');
    }
  }

  Future<AppResult<ServiceOrderModel>> updateOrderStatus({
    required String orderId,
    required MoveServiceStatus status,
  }) async {
    if (!isAvailable) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    final activeClient = _effectiveClient;
    if (activeClient == null) {
      return AppResult.failure('Layanan belum terhubung. Periksa koneksi internet Anda.');
    }
    try {
      final res = await activeClient
          .from('service_orders')
          .update({'status': status.name})
          .eq('id', orderId)
          .select()
          .maybeSingle();
      if (res == null) {
        return AppResult.failure('Pesanan tidak ditemukan di server.');
      }
      return AppResult.success(ServiceOrderModel.fromJson(res));
    } catch (e) {
      return AppResult.failure('Gagal memperbarui status pesanan: $e');
    }
  }
}
