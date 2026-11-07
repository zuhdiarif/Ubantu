import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/mitra_repository_impl.dart';
import 'package:ubantu/data/services/supabase_mitra_service.dart';
import 'package:ubantu/data/services/supabase_order_service.dart';
import 'package:ubantu/data/models/app_enums.dart';
import 'package:ubantu/data/models/service_order_model.dart';
import 'package:ubantu/data/models/task_model.dart';

class FakeRemoteMitraServiceForSelfOrder extends SupabaseMitraService {
  final String _currentUserId;

  FakeRemoteMitraServiceForSelfOrder(this._currentUserId);

  @override
  bool get isAvailable => true;

  @override
  String? get currentUserId => _currentUserId;

  @override
  Future<AppResult<ServiceOrderModel>> acceptOrder({
    required String orderId,
    required String helperId,
    String? requesterId,
  }) async {
    if (requesterId != null && requesterId.isNotEmpty && requesterId == helperId) {
      return AppResult.failure('Tidak dapat mengambil pesanan milik sendiri.');
    }
    return AppResult.success(
      ServiceOrderModel(
        id: orderId,
        requesterId: requesterId ?? 'other-user',
        category: ServiceCategory.pindahKos,
        status: MoveServiceStatus.accepted,
        locationOrigin: 'Origin',
        locationDestination: 'Dest',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        itemDescription: 'Barang',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi',
        createdAt: DateTime.now(),
        helperId: helperId,
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServiceOrderModel and TaskModel requester_name Enrich Tests', () {
    test('ServiceOrderModel parses requester_name from root json', () {
      final json = {
        'id': 'ord-101',
        'requester_id': 'user-101',
        'requester_name': 'Ahmad Dahlan',
        'category': 'pindahKos',
        'status': 'waiting',
        'location_origin': 'Kos Veteran',
        'location_destination': 'Kos Suhat',
        'scheduled_at': DateTime.now().toIso8601String(),
        'item_description': 'Lemari kecil',
        'barter_type': 'makanan',
        'barter_description': 'Nasi Padang',
        'created_at': DateTime.now().toIso8601String(),
      };

      final order = ServiceOrderModel.fromJson(json);
      expect(order.requesterName, 'Ahmad Dahlan');
      expect(order.toJson()['requester_name'], 'Ahmad Dahlan');
    });

    test('ServiceOrderModel parses requester_name from joined profiles map', () {
      final json = {
        'id': 'ord-102',
        'requester_id': 'user-102',
        'profiles': {'full_name': 'Dewi Sartika'},
        'category': 'bersihKos',
        'status': 'waiting',
        'location_origin': 'Kos Sigura',
        'location_destination': 'Kos Sigura',
        'scheduled_at': DateTime.now().toIso8601String(),
        'item_description': 'Bersih kamar',
        'barter_type': 'makanan',
        'barter_description': 'Ayam Geprek',
        'created_at': DateTime.now().toIso8601String(),
      };

      final order = ServiceOrderModel.fromJson(json);
      expect(order.requesterName, 'Dewi Sartika');
      expect(order.toJson()['requester_name'], 'Dewi Sartika');
    });

    test('TaskModel.fromServiceOrder inherits requesterName from order', () {
      final order = ServiceOrderModel(
        id: 'ord-103',
        requesterId: 'user-103',
        requesterName: 'Budi Utomo',
        category: ServiceCategory.antarJemput,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Gerbang Veteran',
        locationDestination: 'Stasiun Kota Baru',
        scheduledAt: DateTime.now().add(const Duration(hours: 3)),
        itemDescription: 'Antar motor',
        barterType: BarterType.barang,
        barterDescription: 'Voucher',
        createdAt: DateTime.now(),
      );

      final task = TaskModel.fromServiceOrder(order);
      expect(task.requesterName, 'Budi Utomo');
      expect(task.toJson()['requester_name'], 'Budi Utomo');
    });

    test('TaskModel.fromJson prioritizes requester_name, then profiles.full_name, then receiver_name, then fallback', () {
      final taskFromRequesterName = TaskModel.fromJson({
        'id': 't-1',
        'category': 'pindahKos',
        'requester_name': 'Siti Hajar',
        'receiver_name': 'Penerima A',
      });
      expect(taskFromRequesterName.requesterName, 'Siti Hajar');

      final taskFromProfile = TaskModel.fromJson({
        'id': 't-2',
        'category': 'pindahKos',
        'profiles': {'full_name': 'Habibie'},
        'receiver_name': 'Penerima B',
      });
      expect(taskFromProfile.requesterName, 'Habibie');

      final taskFromReceiver = TaskModel.fromJson({
        'id': 't-3',
        'category': 'antarJemput',
        'receiver_name': 'Raden Saleh',
      });
      expect(taskFromReceiver.requesterName, 'Raden Saleh');

      final taskDefault = TaskModel.fromJson({
        'id': 't-4',
        'category': 'bersihKos',
      });
      expect(taskDefault.requesterName, 'Mahasiswa UB');
    });
  });

  group('Self-Order Visibility and Acceptance Guard Tests', () {
    test('MitraRepositoryImpl.acceptOrder rejects self order in local/offline mode', () async {
      final repo = MitraRepositoryImpl();
      final selfOrder = ServiceOrderModel(
        id: 'ord-self-1',
        requesterId: 'mitra_user_1',
        category: ServiceCategory.pindahKos,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Origin',
        locationDestination: 'Dest',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        itemDescription: 'Barang',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi',
        createdAt: DateTime.now(),
      );
      repo.seedIncomingOrdersForTesting([selfOrder]);

      final res = await repo.acceptOrder('ord-self-1');
      expect(res.isSuccess, isFalse);
      expect(res.errorMessage, 'Tidak dapat mengambil pesanan milik sendiri.');
      expect(repo.activeOrderForTesting, isNull);
    });

    test('MitraRepositoryImpl.acceptOrder rejects self order in remote mode', () async {
      final fakeRemoteService = FakeRemoteMitraServiceForSelfOrder('mitra-99');
      final repo = MitraRepositoryImpl(mitraService: fakeRemoteService);

      final selfOrder = ServiceOrderModel(
        id: 'ord-self-2',
        requesterId: 'mitra-99',
        category: ServiceCategory.bersihKos,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Origin',
        locationDestination: 'Dest',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        itemDescription: 'Barang',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi',
        createdAt: DateTime.now(),
      );
      repo.seedIncomingOrdersForTesting([selfOrder]);

      final res = await repo.acceptOrder('ord-self-2');
      expect(res.isSuccess, isFalse);
      expect(res.errorMessage, 'Tidak dapat mengambil pesanan milik sendiri.');
      expect(repo.activeOrderForTesting, isNull);
    });

    test('MitraRepositoryImpl.getIncomingOrders filters out own orders in local mode', () async {
      final repo = MitraRepositoryImpl();
      final ownOrder = ServiceOrderModel(
        id: 'ord-own',
        requesterId: 'mitra_user_1',
        category: ServiceCategory.pindahKos,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Origin',
        locationDestination: 'Dest',
        scheduledAt: DateTime.now(),
        itemDescription: 'Barang',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi',
        createdAt: DateTime.now(),
      );
      final otherOrder = ServiceOrderModel(
        id: 'ord-other',
        requesterId: 'mahasiswa_other',
        category: ServiceCategory.pindahKos,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Origin',
        locationDestination: 'Dest',
        scheduledAt: DateTime.now(),
        itemDescription: 'Barang',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi',
        createdAt: DateTime.now(),
      );
      repo.seedIncomingOrdersForTesting([ownOrder, otherOrder]);

      final res = await repo.getIncomingOrders();
      expect(res.isSuccess, isTrue);
      expect(res.data!.any((o) => o.id == 'ord-own'), isFalse);
      expect(res.data!.any((o) => o.id == 'ord-other'), isTrue);
    });

    test('SupabaseOrderService.acceptOrder rejects invalid helperId and self-acceptance', () async {
      final orderService = SupabaseOrderService();

      final resInvalidHelper = await orderService.acceptOrder('ord-mitra-01', '   ');
      expect(resInvalidHelper.isSuccess, isFalse);
      expect(resInvalidHelper.errorMessage, 'ID mitra tidak valid.');

      final resSelfAccept = await orderService.acceptOrder('ord-mitra-01', 'req_mahasiswa_1');
      expect(resSelfAccept.isSuccess, isFalse);
      expect(resSelfAccept.errorMessage, 'Tidak dapat mengambil pesanan milik sendiri.');
    });

    test('SupabaseOrderService.getActiveOrders filters out excludeRequesterId', () async {
      final orderService = SupabaseOrderService();
      final res = await orderService.getActiveOrders(excludeRequesterId: 'req_mahasiswa_1');

      expect(res.isSuccess, isTrue);
      expect(res.data!.any((o) => o.requesterId == 'req_mahasiswa_1'), isFalse);
      expect(res.data!.length, 2);
    });

    test('SupabaseMitraService.acceptOrder rejects when requesterId matches helperId', () async {
      final mitraService = SupabaseMitraService();
      final res = await mitraService.acceptOrder(
        orderId: 'dummy-ord',
        helperId: 'helper-user-1',
        requesterId: 'helper-user-1',
      );

      expect(res.isSuccess, isFalse);
      expect(res.errorMessage, 'Tidak dapat mengambil pesanan milik sendiri.');
    });
  });
}
