import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/app_enums.dart';
import 'package:ubantu/domain/models/chat_message_model.dart';
import 'package:ubantu/domain/models/chat_room_model.dart';
import 'package:ubantu/domain/models/service_order_model.dart';
import 'package:ubantu/domain/repositories/chat_repository.dart';
import 'package:ubantu/domain/repositories/service_order_repository.dart';
import 'package:ubantu/presentation/providers/chat_provider.dart';
import 'package:ubantu/presentation/providers/service_order_provider.dart';

class _FakeRealtimeOrderRepository implements IServiceOrderRepository {
  final StreamController<ServiceOrderModel?> controller =
      StreamController<ServiceOrderModel?>.broadcast();

  @override
  Stream<ServiceOrderModel?> watchOrder(String orderId) => controller.stream;

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
  ) async =>
      AppResult.failure('noop');

  @override
  Future<AppResult<ServiceOrderModel>> acceptOrder(
    String orderId,
    String helperId,
  ) async =>
      AppResult.failure('noop');

  @override
  Future<AppResult<ServiceOrderModel>> completeOrderWithProof(
    String orderId,
    File photo,
  ) async =>
      AppResult.failure('noop');

  @override
  Future<AppResult<ServiceOrderModel>> confirmBarter(
    String orderId,
  ) async =>
      AppResult.failure('noop');
}

class _FakeRealtimeChatRepository implements IChatRepository {
  final StreamController<List<ChatMessageModel>> controller =
      StreamController<List<ChatMessageModel>>.broadcast();

  @override
  Stream<List<ChatMessageModel>> watchMessages(String roomId) => controller.stream;

  @override
  Future<AppResult<List<ChatRoomModel>>> getChatRooms() async => AppResult.success([]);

  @override
  Future<AppResult<ChatRoomModel?>> getChatRoomByOrderId(String orderId) async =>
      AppResult.success(null);

  @override
  Future<AppResult<List<ChatMessageModel>>> getMessages(String roomId) async =>
      AppResult.success([]);

  @override
  Future<AppResult<ChatMessageModel>> sendMessage(
    String roomId,
    String message, {
    String? attachmentUrl,
  }) async =>
      AppResult.failure('noop');

  @override
  Future<AppResult<bool>> markMessagesAsRead(String roomId) async =>
      AppResult.success(true);
}

void main() {
  group('Realtime Stream Unit Tests', () {
    test('ServiceOrderProvider reacts to stream events and updates activeOrder', () async {
      final fakeRepo = _FakeRealtimeOrderRepository();
      final provider = ServiceOrderProvider(repository: fakeRepo);

      final initialOrder = ServiceOrderModel(
        id: 'ord-stream-1',
        requesterId: 'user-1',
        category: ServiceCategory.antarJemput,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Origin',
        locationDestination: 'Destination',
        scheduledAt: DateTime.now(),
        itemDescription: 'Helm',
        barterType: BarterType.makanan,
        barterDescription: 'Nasi Goreng',
        createdAt: DateTime.now(),
      );

      provider.subscribeToOrder('ord-stream-1');
      fakeRepo.controller.add(initialOrder);
      await pumpEventQueue();

      expect(provider.activeOrder?.id, 'ord-stream-1');
      expect(provider.activeOrder?.status, MoveServiceStatus.waiting);
      expect(provider.myOrders.length, 1);

      final acceptedOrder = initialOrder.copyWith(status: MoveServiceStatus.accepted);
      fakeRepo.controller.add(acceptedOrder);
      await pumpEventQueue();

      expect(provider.activeOrder?.status, MoveServiceStatus.accepted);
      expect(provider.myOrders.first.status, MoveServiceStatus.accepted);

      provider.cancelOrderSubscription();
      final completedOrder = initialOrder.copyWith(status: MoveServiceStatus.completed);
      fakeRepo.controller.add(completedOrder);
      await pumpEventQueue();

      expect(provider.activeOrder?.status, MoveServiceStatus.accepted);
    });

    test('ServiceOrderProvider cancels stream on dispose', () async {
      final fakeRepo = _FakeRealtimeOrderRepository();
      final provider = ServiceOrderProvider(repository: fakeRepo);

      final order = ServiceOrderModel(
        id: 'ord-stream-2',
        requesterId: 'user-1',
        category: ServiceCategory.bersihKos,
        status: MoveServiceStatus.waiting,
        locationOrigin: 'Origin',
        locationDestination: 'Destination',
        scheduledAt: DateTime.now(),
        itemDescription: 'Kamar',
        barterType: BarterType.makanan,
        barterDescription: 'Roti',
        createdAt: DateTime.now(),
      );

      provider.subscribeToOrder('ord-stream-2');
      provider.dispose();

      fakeRepo.controller.add(order);
      await pumpEventQueue();

      expect(provider.activeOrder, isNull);
    });

    test('ChatProvider receives streamed messages via subscribeToRoom and cancels on unsubscribe', () async {
      final fakeRepo = _FakeRealtimeChatRepository();
      final provider = ChatProvider(repository: fakeRepo);

      final room = ChatRoomModel(
        id: 'room-1',
        orderId: 'order-1',
        orderNumber: '#UB001',
        serviceTitle: 'Antar Jemput',
        serviceStatus: 'SEDANG BERLANGSUNG',
        otherUserName: 'Mitra',
        otherUserFaculty: 'FILKOM UB',
        lastMessage: 'Halo',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        isActive: true,
        itemSummary: 'Summary',
        pickupLocation: 'A',
        destinationLocation: 'B',
        totalPrice: 'Barter',
      );

      provider.setActiveRoom(room);

      final msg1 = ChatMessageModel(
        id: 'msg-1',
        roomId: 'room-1',
        senderId: 'driver-1',
        senderName: 'Mitra',
        message: 'Saya sudah sampai',
        isMe: false,
        isRead: false,
        createdAt: DateTime.now(),
      );

      fakeRepo.controller.add([msg1]);
      await pumpEventQueue();

      expect(provider.activeMessages.length, 1);
      expect(provider.activeMessages.first.message, 'Saya sudah sampai');

      final msg2 = ChatMessageModel(
        id: 'msg-2',
        roomId: 'room-1',
        senderId: 'user-me',
        senderName: 'Saya',
        message: 'Siap meluncur',
        isMe: true,
        isRead: true,
        createdAt: DateTime.now(),
      );

      fakeRepo.controller.add([msg1, msg2]);
      await pumpEventQueue();

      expect(provider.activeMessages.length, 2);

      provider.unsubscribeRoom();
      fakeRepo.controller.add([
        msg1,
        msg2,
        ChatMessageModel(
          id: 'msg-3',
          roomId: 'room-1',
          senderId: 'driver-1',
          senderName: 'Mitra',
          message: 'Ditunggu',
          isMe: false,
          isRead: false,
          createdAt: DateTime.now(),
        ),
      ]);
      await pumpEventQueue();

      expect(provider.activeMessages.length, 2);
    });
  });
}
