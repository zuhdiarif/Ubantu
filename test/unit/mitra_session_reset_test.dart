import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/auth_repository_impl.dart';
import 'package:ubantu/data/repositories/mitra_repository_impl.dart';
import 'package:ubantu/data/services/supabase_mitra_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';

class FakeMitraServiceForReset extends SupabaseMitraService {
  @override
  bool get isAvailable => true;

  @override
  String? get currentUserId => 'mitra-42';

  bool failOnlineStatus = false;
  bool failDeclineOrder = false;
  Map<String, dynamic>? activeOrderToReturn;

  @override
  Future<Map<String, dynamic>?> fetchActiveOrder(String userId) async {
    return activeOrderToReturn;
  }

  @override
  Future<AppResult<void>> updateOnlineStatus(String userId, bool isOnline) async {
    if (failOnlineStatus) {
      return AppResult.failure('Koneksi terputus');
    }
    return AppResult.success(null);
  }

  @override
  Future<AppResult<void>> recordDeclinedOrder({
    required String mitraId,
    required String orderId,
  }) async {
    if (failDeclineOrder) {
      return AppResult.failure('Gagal mencatat di server');
    }
    return AppResult.success(null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mitra Stale Active Order & Error Rollback Tests', () {
    late FakeMitraServiceForReset fakeService;
    late MitraRepositoryImpl repo;

    setUp(() {
      fakeService = FakeMitraServiceForReset();
      repo = MitraRepositoryImpl(mitraService: fakeService);
    });

    test('getActiveOrder clears stale order when remote returns none', () async {
      final sampleOrder = ServiceOrderModel(
        id: 'ord-stale-1',
        requesterId: 'user-req-1',
        category: ServiceCategory.pindahKos,
        status: MoveServiceStatus.accepted,
        locationOrigin: 'Origin Kos',
        locationDestination: 'Dest Kos',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        itemDescription: 'Barang pindahan',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi goreng',
        createdAt: DateTime.now(),
      );

      repo.seedActiveOrderForTesting(sampleOrder);
      expect(repo.activeOrderForTesting, isNotNull);

      fakeService.activeOrderToReturn = null;

      final res = await repo.getActiveOrder();
      expect(res.isSuccess, isTrue);
      expect(res.data, isNull);
      expect(repo.activeOrderForTesting, isNull);
    });

    test('toggleOnlineStatus rollback when service returns failure', () async {
      fakeService.failOnlineStatus = true;
      final provider = MitraProvider(repository: repo);

      expect(provider.isOnline, isTrue);

      final ok = await provider.toggleOnlineStatus(false);

      expect(ok, isFalse);
      expect(provider.isOnline, isTrue);
      expect(provider.errorMessage, contains('Koneksi terputus'));

      final profileRes = await repo.getMitraProfile();
      expect(profileRes.data!.isOnline, isTrue);
    });

    test('declineOrder failure does not add to declined set', () async {
      fakeService.failDeclineOrder = true;

      final res = await repo.declineOrder('order-fail-decline');

      expect(res.isSuccess, isFalse);
      expect(res.errorMessage, contains('Gagal mencatat di server'));
      expect(repo.declinedOrderIdsForTesting.contains('order-fail-decline'), isFalse);
    });
  });

  group('Session Reset Tests', () {
    test('ServiceLocator.clearSessionCaches resets mitra repository state', () async {
      final repo = MitraRepositoryImpl();
      ServiceLocator.resetForTesting(mitraRepository: repo);

      final toggleRes = await repo.toggleOnlineStatus(false);
      expect(toggleRes.isSuccess, isTrue);
      expect((await repo.getMitraProfile()).data!.isOnline, isFalse);

      final declineRes = await repo.declineOrder('ord-mitra-01');
      expect(declineRes.isSuccess, isTrue);
      expect(repo.declinedOrderIdsForTesting.contains('ord-mitra-01'), isTrue);

      final sampleOrder = ServiceOrderModel(
        id: 'ord-active-dummy',
        requesterId: 'user-dummy',
        category: ServiceCategory.bersihKos,
        status: MoveServiceStatus.accepted,
        locationOrigin: 'Origin',
        locationDestination: 'Dest',
        scheduledAt: DateTime.now(),
        itemDescription: 'Item',
        barterType: BarterType.jasa,
        barterDescription: 'Barter',
        createdAt: DateTime.now(),
      );
      repo.seedActiveOrderForTesting(sampleOrder);
      expect(repo.activeOrderForTesting, isNotNull);

      ServiceLocator.instance.clearSessionCaches();

      expect((await repo.getMitraProfile()).data!.isOnline, isTrue);
      expect(repo.declinedOrderIdsForTesting.isEmpty, isTrue);
      expect(repo.activeOrderForTesting, isNull);
    });

    test('AuthProvider.logout calls ServiceLocator.clearSessionCaches', () async {
      final repo = MitraRepositoryImpl();
      final authRepo = AuthRepositoryImpl();
      ServiceLocator.resetForTesting(
        mitraRepository: repo,
        authRepository: authRepo,
      );

      await repo.toggleOnlineStatus(false);
      expect((await repo.getMitraProfile()).data!.isOnline, isFalse);

      final authProvider = AuthProvider(repository: authRepo);
      await authProvider.logout();

      expect((await repo.getMitraProfile()).data!.isOnline, isTrue);
      expect(repo.declinedOrderIdsForTesting.isEmpty, isTrue);
      expect(repo.activeOrderForTesting, isNull);
    });

    test('MitraProvider.resetSession clears in-memory state', () async {
      final provider = MitraProvider();
      final sampleOrder = ServiceOrderModel(
        id: 'active-1',
        requesterId: 'user-1',
        category: ServiceCategory.antarJemput,
        status: MoveServiceStatus.inProgress,
        locationOrigin: 'Origin',
        locationDestination: 'Dest',
        scheduledAt: DateTime.now(),
        itemDescription: 'Antar',
        barterType: BarterType.makanan,
        barterDescription: 'Snack',
        createdAt: DateTime.now(),
      );
      provider.setActiveOrder(sampleOrder);
      expect(provider.activeOrder, isNotNull);

      provider.resetSession();

      expect(provider.profile, isNull);
      expect(provider.activeOrder, isNull);
      expect(provider.incomingOrders.isEmpty, isTrue);
      expect(provider.completedOrders.isEmpty, isTrue);
      expect(provider.earningsHistory.isEmpty, isTrue);
    });
  });
}