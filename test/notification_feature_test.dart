import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/debug_floating_menu.dart';
import 'package:ubantu/core/di/service_locator.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/notification_repository_impl.dart';
import 'package:ubantu/data/services/notification_service.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/chat_room_model.dart';
import 'package:ubantu/domain/models/notification_model.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/models/user_model.dart';
import 'package:ubantu/domain/repositories/auth_repository.dart';
import 'package:ubantu/domain/repositories/chat_repository.dart';
import 'package:ubantu/domain/repositories/mitra_repository.dart';
import 'package:ubantu/domain/repositories/notification_repository.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';
import 'package:ubantu/presentation/providers/auth_provider.dart';
import 'package:ubantu/presentation/providers/chat_provider.dart';
import 'package:ubantu/presentation/providers/mitra_provider.dart';
import 'package:ubantu/presentation/providers/notification_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';
import 'package:ubantu/presentation/providers/task_provider.dart';
import 'package:ubantu/presentation/views/home_view.dart';
import 'package:ubantu/presentation/views/notification_view.dart';

import 'package:ubantu/domain/models/chat_message_model.dart';
import 'package:ubantu/domain/models/mitra_earning_item_model.dart';
import 'package:ubantu/domain/models/mitra_profile_model.dart';

class MockNotificationRepo implements INotificationRepository {
  final List<NotificationModel> _list = [];

  @override
  List<NotificationModel> getNotifications() => List.unmodifiable(_list);

  @override
  int getUnreadCount() => _list.where((n) => !n.isRead).length;

  @override
  void addNotification(String title, String message, {String type = 'general'}) {
    _list.insert(
      0,
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'usr_test',
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  void markAllAsRead() {
    for (int i = 0; i < _list.length; i++) {
      _list[i] = _list[i].copyWith(isRead: true);
    }
  }
}

class MockOrderRepo implements IServiceOrderRepository {
  @override
  Future<AppResult<List<ServiceOrderModel>>> getActiveOrders() async =>
      AppResult.success([]);

  @override
  Future<AppResult<List<ServiceOrderModel>>> getOrderHistory(String userId) async =>
      AppResult.success([]);

  @override
  Future<AppResult<ServiceOrderModel>> createOrder(ServiceOrderModel order) async =>
      AppResult.success(order);

  @override
  Future<AppResult<ServiceOrderModel>> updateOrderStatus(
    String orderId,
    MoveServiceStatus status,
  ) async {
    return AppResult.success(
      ServiceOrderModel(
        id: orderId,
        requesterId: 'usr_1',
        category: ServiceCategory.antarJemput,
        status: status,
        locationOrigin: 'Origin',
        locationDestination: 'Destination',
        scheduledAt: DateTime.now(),
        itemDescription: 'Item',
        barterType: BarterType.makanan,
        barterDescription: 'Snack',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<AppResult<ServiceOrderModel>> acceptOrder(String orderId, String helperId) async =>
      AppResult.success(
        ServiceOrderModel(
          id: orderId,
          requesterId: 'usr_1',
          helperId: helperId,
          category: ServiceCategory.antarJemput,
          status: MoveServiceStatus.accepted,
          locationOrigin: 'Origin',
          locationDestination: 'Destination',
          scheduledAt: DateTime.now(),
          itemDescription: 'Item',
          barterType: BarterType.makanan,
          barterDescription: 'Snack',
          createdAt: DateTime.now(),
        ),
      );
}

class MockMitraRepo implements IMitraRepository {
  ServiceOrderModel? activeOrder;

  @override
  Future<AppResult<bool>> updateOrderStatus(String orderId, MoveServiceStatus status) async =>
      AppResult.success(true);

  @override
  Future<AppResult<MitraProfileModel>> getMitraProfile() async =>
      AppResult.failure('none');
  @override
  Future<AppResult<bool>> toggleOnlineStatus(bool isOnline) async => AppResult.success(isOnline);
  @override
  Future<AppResult<bool>> updateServiceCategories(List<ServiceCategory> categories) async =>
      AppResult.success(true);
  @override
  Future<AppResult<List<ServiceOrderModel>>> getIncomingOrders() async => AppResult.success([]);
  @override
  Future<AppResult<ServiceOrderModel?>> getActiveOrder() async => AppResult.success(activeOrder);
  @override
  Future<AppResult<bool>> acceptOrder(String orderId) async => AppResult.success(true);
  @override
  Future<AppResult<bool>> declineOrder(String orderId) async => AppResult.success(true);
  @override
  Future<AppResult<List<ServiceOrderModel>>> getCompletedOrders() async => AppResult.success([]);
  @override
  Future<AppResult<List<MitraEarningItemModel>>> getEarningsHistory() async => AppResult.success([]);
}

class MockChatRepo implements IChatRepository {
  final List<ChatRoomModel> rooms;
  MockChatRepo({this.rooms = const []});

  @override
  Future<AppResult<List<ChatRoomModel>>> getChatRooms() async => AppResult.success(rooms);
  @override
  Future<AppResult<ChatRoomModel?>> getChatRoomByOrderId(String orderId) async => AppResult.success(null);
  @override
  Future<AppResult<List<ChatMessageModel>>> getMessages(String roomId) async => AppResult.success([]);
  @override
  Future<AppResult<ChatMessageModel>> sendMessage(String roomId, String message, {String? attachmentUrl}) async =>
      AppResult.failure('noop');
  @override
  Future<AppResult<bool>> markMessagesAsRead(String roomId) async => AppResult.success(true);
}

class MockAuthRepo implements IAuthRepository {
  UserModel? user;
  MockAuthRepo({this.user});

  @override
  UserModel? getCurrentUser() => user;

  @override
  bool didSignUpReturnSession() => false;

  @override
  Future<AppResult<UserModel>> login(String email, String password) async =>
      user != null ? AppResult.success(user!) : AppResult.failure('Not found');

  @override
  Future<void> logout() async {
    user = null;
  }

  @override
  Future<AppResult<bool>> sendOtp(String email) async => AppResult.success(true);

  @override
  Future<AppResult<bool>> signInWithGoogle() async => AppResult.success(true);

  @override
  Future<AppResult<UserModel>> signUp(String email, String password, Map<String, dynamic> metadata) async =>
      user != null ? AppResult.success(user!) : AppResult.failure('Not found');

  @override
  Future<AppResult<bool>> verifyOtp(String email, String token) async => AppResult.success(true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationModel Tests', () {
    test('default type is general', () {
      final notif = NotificationModel(
        id: '1',
        userId: 'u1',
        title: 'Title',
        message: 'Message',
        createdAt: DateTime.now(),
      );
      expect(notif.type, 'general');
      expect(notif.isRead, false);
    });

    test('toJson and fromJson preserves type and fields', () {
      final now = DateTime.now();
      final notif = NotificationModel(
        id: '2',
        userId: 'u1',
        title: 'Driver Tiba',
        message: 'Driver sudah sampai',
        type: 'order',
        isRead: true,
        createdAt: now,
      );

      final json = notif.toJson();
      expect(json['type'], 'order');
      expect(json['title'], 'Driver Tiba');

      final fromJson = NotificationModel.fromJson(json);
      expect(fromJson.type, 'order');
      expect(fromJson.isRead, true);
      expect(fromJson.id, '2');
    });

    test('copyWith works properly', () {
      final notif = NotificationModel(
        id: '3',
        userId: 'u1',
        title: 'Title',
        message: 'Msg',
        type: 'general',
        createdAt: DateTime.now(),
      );

      final updated = notif.copyWith(type: 'ktm', isRead: true);
      expect(updated.type, 'ktm');
      expect(updated.isRead, true);
      expect(updated.title, 'Title');
    });
  });

  group('NotificationService & Repository Tests', () {
    test('service adds and modifies notifications', () {
      final service = NotificationService();
      service.clear();
      expect(service.notifications.isEmpty, true);
      expect(service.unreadCount, 0);

      service.addNotification('Title 1', 'Message 1', type: 'order');
      expect(service.notifications.length, 1);
      expect(service.unreadCount, 1);
      expect(service.notifications.first.type, 'order');

      final id = service.notifications.first.id;
      service.markAsRead(id);
      expect(service.unreadCount, 0);
      expect(service.notifications.first.isRead, true);

      service.addNotification('Title 2', 'Message 2', type: 'ktm');
      expect(service.unreadCount, 1);
      service.markAllAsRead();
      expect(service.unreadCount, 0);

      service.deleteNotification(id);
      expect(service.notifications.length, 1);
    });

    test('repository delegates to service correctly', () {
      final service = NotificationService();
      service.clear();
      final repo = NotificationRepositoryImpl(service: service);

      repo.addNotification('Test', 'Content', type: 'chat');
      expect(repo.getNotifications().length, 1);
      expect(repo.getUnreadCount(), 1);
      expect(repo.getNotifications().first.type, 'chat');

      repo.markAllAsRead();
      expect(repo.getUnreadCount(), 0);
    });
  });

  group('NotificationProvider Tests', () {
    test('filter tabs separate notifications by category', () {
      final service = NotificationService();
      service.clear();
      final repo = NotificationRepositoryImpl(service: service);
      final provider = NotificationProvider(repository: repo);

      provider.addNotification('Order Update', 'Driver tiba', type: 'order');
      provider.addNotification('KTM Update', 'KTM disetujui', type: 'ktm');
      provider.addNotification('Chat Update', 'Halo kak', type: 'chat');
      provider.addNotification('Promo Update', 'Ada promo baru', type: 'general');

      expect(provider.notifications.length, 4);

      provider.setFilter('Semua');
      expect(provider.filteredNotifications.length, 4);

      provider.setFilter('Pesanan');
      expect(provider.filteredNotifications.length, 1);
      expect(provider.filteredNotifications.first.type, 'order');

      provider.setFilter('KTM');
      expect(provider.filteredNotifications.length, 1);
      expect(provider.filteredNotifications.first.type, 'ktm');

      provider.setFilter('Pesan');
      expect(provider.filteredNotifications.length, 1);
      expect(provider.filteredNotifications.first.type, 'chat');
    });

    test('markAsRead and deleteNotification via provider', () {
      final service = NotificationService();
      service.clear();
      final repo = NotificationRepositoryImpl(service: service);
      final provider = NotificationProvider(repository: repo);

      provider.addNotification('Test', 'Msg');
      expect(provider.unreadCount, 1);
      final id = provider.notifications.first.id;

      provider.markAsRead(id);
      expect(provider.unreadCount, 0);

      provider.deleteNotification(id);
      expect(provider.notifications.isEmpty, true);
    });
  });

  group('Feature Trigger Notifications Tests', () {
    test('ServiceOrderProvider notifies when driver arrives (inProgress) and completes', () async {
      final notifRepo = MockNotificationRepo();
      final orderRepo = MockOrderRepo();
      final provider = ServiceOrderProvider(
        repository: orderRepo,
        notificationRepository: notifRepo,
      );

      await provider.updateStatus('order_123', MoveServiceStatus.inProgress);
      expect(notifRepo.getNotifications().length, 1);
      expect(notifRepo.getNotifications().first.type, 'order');
      expect(notifRepo.getNotifications().first.title.contains('Driver Sudah Tiba'), true);

      await provider.updateStatus('order_123', MoveServiceStatus.completed);
      expect(notifRepo.getNotifications().length, 2);
      expect(notifRepo.getNotifications().first.type, 'order');
      expect(notifRepo.getNotifications().first.title.contains('Selesai'), true);
    });

    test('AuthProvider notifies when KTM verification status changes pending -> verified', () {
      final notifRepo = MockNotificationRepo();
      final user = const UserModel(
        id: 'usr_test',
        fullName: 'Mahasiswa Test',
        email: 'test@student.ub.ac.id',
        phoneNumber: '08123',
        nim: '21515020',
        verificationStatus: KtmVerificationStatus.pending,
      );
      final authRepo = MockAuthRepo(user: user);
      final provider = AuthProvider(
        repository: authRepo,
        notificationRepository: notifRepo,
      );

      expect(notifRepo.getNotifications().isEmpty, true);

      provider.setKtmVerificationStatus(KtmVerificationStatus.verified);
      expect(notifRepo.getNotifications().length, 1);
      expect(notifRepo.getNotifications().first.type, 'ktm');
      expect(notifRepo.getNotifications().first.title.contains('Verifikasi KTM Berhasil'), true);
    });

    test('ChatProvider notifies when new incoming message arrives', () async {
      final notifRepo = MockNotificationRepo();
      final room = ChatRoomModel(
        id: 'room_1',
        orderId: 'order_1',
        orderNumber: '#UB-1234',
        serviceTitle: 'Antar Jemput',
        serviceStatus: 'SEDANG BERLANGSUNG',
        otherUserName: 'Kak Budi',
        otherUserFaculty: 'FILKOM UB',
        lastMessage: 'Saya sudah di gerbang veteran kak',
        lastMessageTime: DateTime.now(),
        unreadCount: 1,
        isActive: true,
        itemSummary: 'Antar jemput Filkom',
        pickupLocation: 'Gerbang Veteran',
        destinationLocation: 'Gedung F',
      );
      final chatRepo = MockChatRepo(rooms: [room]);
      final chatProvider = ChatProvider(
        repository: chatRepo,
        notificationRepository: notifRepo,
      );

      await chatProvider.loadRooms();
      expect(notifRepo.getNotifications().length, 1);
      expect(notifRepo.getNotifications().first.type, 'chat');
      expect(notifRepo.getNotifications().first.title.contains('Kak Budi'), true);
      expect(notifRepo.getNotifications().first.message, 'Saya sudah di gerbang veteran kak');
    });

    test('MitraProvider notifies when active order status changes to inProgress and completed', () async {
      final notifRepo = MockNotificationRepo();
      final activeOrder = ServiceOrderModel(
        id: 'order_mitra_1',
        requesterId: 'usr_req',
        category: ServiceCategory.antarJemput,
        status: MoveServiceStatus.accepted,
        locationOrigin: 'Origin',
        locationDestination: 'Destination',
        scheduledAt: DateTime.now(),
        itemDescription: 'Item',
        barterType: BarterType.makanan,
        barterDescription: 'Snack',
        createdAt: DateTime.now(),
      );
      final mitraRepo = MockMitraRepo()..activeOrder = activeOrder;
      final mitraProvider = MitraProvider(
        repository: mitraRepo,
        notificationRepository: notifRepo,
      );

      await mitraProvider.loadMitraData();
      await mitraProvider.updateActiveOrderStatus(MoveServiceStatus.inProgress);

      expect(notifRepo.getNotifications().any((n) => n.title.contains('Driver Sudah Tiba')), true);

      await mitraProvider.updateActiveOrderStatus(MoveServiceStatus.completed);
      expect(notifRepo.getNotifications().any((n) => n.title.contains('Pesanan Bantuan Selesai')), true);
    });
  });

  group('UI Widgets Tests', () {
    testWidgets('HomeView bell button renders with unread badge counter', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final service = NotificationService();
      service.clear();
      service.addNotification('Driver Tiba', 'Sudah sampai', type: 'order');
      final notifRepo = NotificationRepositoryImpl(service: service);
      final notifProvider = NotificationProvider(repository: notifRepo);

      final authProvider = AuthProvider(repository: ServiceLocator.instance.authRepository);
      final taskProvider = TaskProvider(repository: ServiceLocator.instance.taskRepository);
      final serviceOrderProvider = ServiceOrderProvider(repository: ServiceLocator.instance.serviceOrderRepository);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: notifProvider),
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: taskProvider),
            ChangeNotifierProvider.value(value: serviceOrderProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: HomeView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('NotificationView renders header, filter chips, items, and marks as read', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final service = NotificationService();
      service.clear();
      service.addNotification('Driver Tiba', 'Driver telah tiba di lokasi jemput', type: 'order');
      service.addNotification('KTM Valid', 'KTM kamu telah diverifikasi', type: 'ktm');
      final notifRepo = NotificationRepositoryImpl(service: service);
      final notifProvider = NotificationProvider(repository: notifRepo);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: notifProvider),
          ],
          child: const MaterialApp(
            home: NotificationView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Riwayat Notifikasi'), findsOneWidget);
      expect(find.text('Tandai Dibaca'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Pesanan'), findsOneWidget);
      expect(find.text('KTM'), findsOneWidget);
      expect(find.text('Pesan'), findsOneWidget);

      expect(find.text('Driver Tiba'), findsOneWidget);
      expect(find.text('KTM Valid'), findsOneWidget);

      await tester.tap(find.text('Pesanan'));
      await tester.pumpAndSettle();

      expect(find.text('Driver Tiba'), findsOneWidget);
      expect(find.text('KTM Valid'), findsNothing);

      await tester.tap(find.text('Tandai Dibaca'));
      await tester.pumpAndSettle();
      expect(notifProvider.unreadCount, 0);
    });

    testWidgets('DebugFloatingMenu displays Riwayat Notifikasi route', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                DebugFloatingMenu(),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.byIcon(Icons.alt_route_rounded));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Riwayat Notifikasi'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Riwayat Notifikasi'), findsOneWidget);
    });
  });
}
