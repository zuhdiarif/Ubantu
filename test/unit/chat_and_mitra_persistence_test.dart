import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/chat_repository_impl.dart';
import 'package:ubantu/data/repositories/mitra_repository_impl.dart';
import 'package:ubantu/data/services/supabase_mitra_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/chat_message_model.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';

class FakeSupabaseMitraService extends SupabaseMitraService {
  @override
  bool get isAvailable => true;

  @override
  String? get currentUserId => 'mitra-user-42';

  bool updateOnlineStatusCalled = false;
  String? lastOnlineUserId;
  bool? lastOnlineStatus;

  bool updateMitraRegistrationCalled = false;
  String? lastRegUserId;
  List<ServiceCategory>? lastCategories;
  String? lastVehicleType;
  String? lastVehiclePlate;

  bool recordDeclinedOrderCalled = false;
  String? lastDeclinedMitraId;
  String? lastDeclinedOrderId;

  bool fetchMitraProfileCalled = false;
  Map<String, dynamic>? profileDataToReturn;

  bool fetchDeclinedOrderIdsCalled = false;
  Set<String> declinedOrderIdsToReturn = {};

  @override
  Future<Map<String, dynamic>?> fetchMitraProfileData(String userId) async {
    fetchMitraProfileCalled = true;
    return profileDataToReturn;
  }

  @override
  Future<AppResult<void>> updateOnlineStatus(String userId, bool isOnline) async {
    updateOnlineStatusCalled = true;
    lastOnlineUserId = userId;
    lastOnlineStatus = isOnline;
    return AppResult.success(null);
  }

  @override
  Future<AppResult<void>> updateMitraRegistration({
    required String userId,
    required List<ServiceCategory> categories,
    String? vehicleType,
    String? vehiclePlate,
  }) async {
    updateMitraRegistrationCalled = true;
    lastRegUserId = userId;
    lastCategories = categories;
    lastVehicleType = vehicleType;
    lastVehiclePlate = vehiclePlate;
    return AppResult.success(null);
  }

  @override
  Future<AppResult<void>> recordDeclinedOrder({
    required String mitraId,
    required String orderId,
  }) async {
    recordDeclinedOrderCalled = true;
    lastDeclinedMitraId = mitraId;
    lastDeclinedOrderId = orderId;
    return AppResult.success(null);
  }

  @override
  Future<Set<String>> fetchDeclinedOrderIds(String mitraId) async {
    fetchDeclinedOrderIdsCalled = true;
    return declinedOrderIdsToReturn;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Issue 3: Chat markMessagesAsRead Ownership Filter Tests', () {
    test('applyMarkMessagesAsReadLocally marks only interlocutor messages as read', () {
      final messages = [
        ChatMessageModel(
          id: 'msg-1',
          roomId: 'room-1',
          senderId: 'user-me',
          senderName: 'Saya',
          message: 'Halo apa kabar?',
          isMe: true,
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        ChatMessageModel(
          id: 'msg-2',
          roomId: 'room-1',
          senderId: 'user-other',
          senderName: 'Budi',
          message: 'Kabar baik!',
          isMe: false,
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        ChatMessageModel(
          id: 'msg-3',
          roomId: 'room-1',
          senderId: 'user-me',
          senderName: 'Saya',
          message: 'Bisa jemput sekarang?',
          isMe: true,
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        ChatMessageModel(
          id: 'msg-4',
          roomId: 'room-1',
          senderId: 'user-other',
          senderName: 'Budi',
          message: 'Siap meluncur.',
          isMe: false,
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ];

      final filtered = ChatRepositoryImpl.applyMarkMessagesAsReadLocally(
        messages,
        currentUserId: 'user-me',
      );

      expect(filtered[0].isRead, isFalse);
      expect(filtered[1].isRead, isTrue);
      expect(filtered[2].isRead, isFalse);
      expect(filtered[3].isRead, isTrue);
    });

    test('applyMarkMessagesAsReadLocally marks all as read when currentUserId is null', () {
      final messages = [
        ChatMessageModel(
          id: 'msg-1',
          roomId: 'room-1',
          senderId: 'user-me',
          senderName: 'Saya',
          message: 'Test 1',
          isMe: true,
          isRead: false,
          createdAt: DateTime.now(),
        ),
        ChatMessageModel(
          id: 'msg-2',
          roomId: 'room-1',
          senderId: 'user-other',
          senderName: 'Budi',
          message: 'Test 2',
          isMe: false,
          isRead: false,
          createdAt: DateTime.now(),
        ),
      ];

      final filtered = ChatRepositoryImpl.applyMarkMessagesAsReadLocally(
        messages,
        currentUserId: null,
      );

      expect(filtered[0].isRead, isTrue);
      expect(filtered[1].isRead, isTrue);
    });

    test('ChatRepositoryImpl markMessagesAsRead updates seeded mock messages respecting currentUserId', () async {
      final repo = ChatRepositoryImpl();
      final seeded = [
        ChatMessageModel(
          id: 'seed-1',
          roomId: 'test-room',
          senderId: 'active-user',
          senderName: 'Active User',
          message: 'Pesan dari active user',
          isMe: true,
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        ChatMessageModel(
          id: 'seed-2',
          roomId: 'test-room',
          senderId: 'other-user',
          senderName: 'Other User',
          message: 'Pesan dari lawan bicara',
          isMe: false,
          isRead: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      ];
      repo.seedMockMessagesForTesting('test-room', seeded);

      final result = await repo.markMessagesAsRead(
        'test-room',
        currentUserId: 'active-user',
      );

      expect(result.isSuccess, isTrue);
      final updated = repo.getMockMessagesForTesting('test-room');
      expect(updated[0].isRead, isFalse);
      expect(updated[1].isRead, isTrue);
    });
  });

  group('Issue 4: Mitra State Persistence to Supabase Tests', () {
    late FakeSupabaseMitraService fakeMitraService;
    late MitraRepositoryImpl mitraRepo;

    setUp(() {
      fakeMitraService = FakeSupabaseMitraService();
      mitraRepo = MitraRepositoryImpl(mitraService: fakeMitraService);
    });

    test('toggleOnlineStatus delegates to SupabaseMitraService when active', () async {
      final res = await mitraRepo.toggleOnlineStatus(false);

      expect(res.isSuccess, isTrue);
      expect(res.data, isFalse);
      expect(fakeMitraService.updateOnlineStatusCalled, isTrue);
      expect(fakeMitraService.lastOnlineUserId, 'mitra-user-42');
      expect(fakeMitraService.lastOnlineStatus, isFalse);
    });

    test('registerMitraCategories delegates category and vehicle updates to SupabaseMitraService', () async {
      final res = await mitraRepo.registerMitraCategories(
        [ServiceCategory.antarJemput, ServiceCategory.bersihKos],
        vehicleType: 'Yamaha NMAX 155',
        vehiclePlate: 'N 8899 AB',
      );

      expect(res.isSuccess, isTrue);
      expect(fakeMitraService.updateMitraRegistrationCalled, isTrue);
      expect(fakeMitraService.lastRegUserId, 'mitra-user-42');
      expect(fakeMitraService.lastCategories, [
        ServiceCategory.antarJemput,
        ServiceCategory.bersihKos,
      ]);
      expect(fakeMitraService.lastVehicleType, 'Yamaha NMAX 155');
      expect(fakeMitraService.lastVehiclePlate, 'N 8899 AB');
    });

    test('declineOrder records declined order in SupabaseMitraService and local set', () async {
      final res = await mitraRepo.declineOrder('ord-to-decline-123');

      expect(res.isSuccess, isTrue);
      expect(fakeMitraService.recordDeclinedOrderCalled, isTrue);
      expect(fakeMitraService.lastDeclinedMitraId, 'mitra-user-42');
      expect(fakeMitraService.lastDeclinedOrderId, 'ord-to-decline-123');
      expect(mitraRepo.declinedOrderIdsForTesting.contains('ord-to-decline-123'), isTrue);
    });

    test('getMitraProfile merges remote profile fields correctly', () async {
      fakeMitraService.profileDataToReturn = {
        'id': 'mitra-user-42',
        'full_name': 'Dewi Sartika',
        'faculty': 'Fakultas Kedokteran',
        'phone_number': '089876543210',
        'is_online': false,
        'mitra_categories': ['antarJemput'],
        'mitra_vehicle_type': 'Honda Beat Street',
        'mitra_vehicle_plate': 'N 3344 CC',
        'avatar_url': 'https://ubantu.app/avatar-dewi.jpg',
      };

      final res = await mitraRepo.getMitraProfile();

      expect(res.isSuccess, isTrue);
      expect(fakeMitraService.fetchMitraProfileCalled, isTrue);

      final profile = res.data!;
      expect(profile.id, 'mitra-user-42');
      expect(profile.name, contains('Dewi Sartika'));
      expect(profile.faculty, 'Fakultas Kedokteran');
      expect(profile.isOnline, isFalse);
      expect(profile.selectedCategories, [ServiceCategory.antarJemput]);
      expect(profile.vehicleInfo, 'Honda Beat Street');
      expect(profile.vehiclePlate, 'N 3344 CC');
      expect(profile.avatarUrl, 'https://ubantu.app/avatar-dewi.jpg');
    });

    test('getIncomingOrders fetches remote declined orders and filters them out', () async {
      fakeMitraService.declinedOrderIdsToReturn = {'ord-declined-remote'};

      final initialOrders = [
        ServiceOrderModel(
          id: 'ord-declined-remote',
          requesterId: 'req-1',
          category: ServiceCategory.pindahKos,
          status: MoveServiceStatus.waiting,
          locationOrigin: 'Origin 1',
          locationDestination: 'Dest 1',
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          itemDescription: 'Barang 1',
          barterType: BarterType.makanan,
          barterDescription: 'Snack',
          createdAt: DateTime.now(),
        ),
        ServiceOrderModel(
          id: 'ord-allowed-remote',
          requesterId: 'req-2',
          category: ServiceCategory.bersihKos,
          status: MoveServiceStatus.waiting,
          locationOrigin: 'Origin 2',
          locationDestination: 'Dest 2',
          scheduledAt: DateTime.now().add(const Duration(hours: 2)),
          itemDescription: 'Barang 2',
          barterType: BarterType.jasa,
          barterDescription: 'Bantu ngetik',
          createdAt: DateTime.now(),
        ),
      ];

      mitraRepo.seedIncomingOrdersForTesting(initialOrders);

      final res = await mitraRepo.getIncomingOrders();

      expect(res.isSuccess, isTrue);
      expect(fakeMitraService.fetchDeclinedOrderIdsCalled, isTrue);

      final orders = res.data!;
      expect(orders.any((o) => o.id == 'ord-declined-remote'), isFalse);
      expect(orders.any((o) => o.id == 'ord-allowed-remote'), isTrue);
    });

    test('MitraProvider registerCategories updates categories and vehicle state', () async {
      final provider = MitraProvider(repository: mitraRepo);

      await provider.registerCategories(
        [ServiceCategory.antarJemput],
        vehicleType: 'Vespa Sprint',
        vehiclePlate: 'N 7788 DD',
      );

      expect(fakeMitraService.updateMitraRegistrationCalled, isTrue);
      expect(fakeMitraService.lastVehicleType, 'Vespa Sprint');
      expect(fakeMitraService.lastVehiclePlate, 'N 7788 DD');
      expect(provider.profile?.selectedCategories, [ServiceCategory.antarJemput]);
      expect(provider.profile?.vehicleInfo, 'Vespa Sprint');
      expect(provider.profile?.vehiclePlate, 'N 7788 DD');
    });
  });
}
