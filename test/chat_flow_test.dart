import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/debug_floating_menu.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/chat_repository_impl.dart';
import 'package:ubantu/domain/models/chat_message_model.dart';
import 'package:ubantu/domain/models/chat_room_model.dart';
import 'package:ubantu/domain/repositories/chat_repository.dart';
import 'package:ubantu/domain/usecases/get_chat_messages_usecase.dart';
import 'package:ubantu/domain/usecases/get_chat_rooms_usecase.dart';
import 'package:ubantu/domain/usecases/send_chat_message_usecase.dart';
import 'package:ubantu/presentation/providers/chat_provider.dart';
import 'package:ubantu/presentation/providers/rating_provider.dart';
import 'package:ubantu/presentation/providers/sos_provider.dart';
import 'package:ubantu/presentation/views/chat/chat_room_view.dart';
import 'package:ubantu/presentation/views/chat/inbox_view.dart';

class FakeChatRepository implements IChatRepository {
  List<ChatRoomModel> rooms = [
    ChatRoomModel(
      id: 'room-test-1',
      orderId: 'order-test-1',
      orderNumber: '#UB2026001',
      serviceTitle: 'Antar Barang',
      serviceStatus: 'SEDANG BERLANGSUNG',
      otherUserName: 'Budi Santoso',
      otherUserFaculty: 'Fakultas Teknik UB',
      lastMessage: 'Baik mas, ditunggu yaa',
      lastMessageTime: DateTime(2026, 10, 24, 13, 12),
      unreadCount: 1,
      isActive: true,
      itemSummary: 'Paket Dokumen & Alat Tulis',
      pickupLocation: 'Mall Olympic Garden',
      destinationLocation: 'Kost Griya Mahasiswa',
      totalPrice: 'Rp 65.000',
    ),
    ChatRoomModel(
      id: 'room-test-2',
      orderId: 'order-test-2',
      orderNumber: '#UB2026002',
      serviceTitle: 'Antar Barang',
      serviceStatus: 'SELESAI',
      otherUserName: 'Putra Budiman',
      otherUserFaculty: 'Fakultas Ilmu Komputer UB',
      lastMessage: 'Saya sudah sampai di lokasi kak',
      lastMessageTime: DateTime(2026, 10, 23, 10, 0),
      unreadCount: 0,
      isActive: false,
      closedAt: DateTime(2026, 10, 23, 14, 30),
      itemSummary: 'Paket Dokumen & Alat Tulis',
      pickupLocation: 'Kost Griya Mahasiswa',
      destinationLocation: 'Kost Griya Mahasiswa',
      totalPrice: 'Rp 65.000',
    ),
  ];

  Map<String, List<ChatMessageModel>> messages = {
    'room-test-1': [
      ChatMessageModel(
        id: 'msg-1',
        roomId: 'room-test-1',
        senderId: 'driver-1',
        senderName: 'Budi Santoso',
        message: 'Halo kak, saya sudah sampai di depan griya ya.',
        isMe: false,
        isRead: true,
        createdAt: DateTime(2026, 10, 24, 18, 37),
      ),
      ChatMessageModel(
        id: 'msg-2',
        roomId: 'room-test-1',
        senderId: 'user-me',
        senderName: 'Saya',
        message: 'Baik mas, tunggu sebentar ya saya turun dulu',
        isMe: true,
        isRead: true,
        createdAt: DateTime(2026, 10, 24, 20, 27),
      ),
    ],
    'room-test-2': [
      ChatMessageModel(
        id: 'msg-201',
        roomId: 'room-test-2',
        senderId: 'driver-2',
        senderName: 'Putra Budiman',
        message: 'Pengiriman selesai kak.',
        isMe: false,
        isRead: true,
        createdAt: DateTime(2026, 10, 23, 14, 30),
      ),
    ],
  };

  @override
  Future<AppResult<List<ChatRoomModel>>> getChatRooms() async {
    return AppResult.success(List.from(rooms));
  }

  @override
  Future<AppResult<ChatRoomModel?>> getChatRoomByOrderId(String orderId) async {
    final match = rooms.cast<ChatRoomModel?>().firstWhere(
          (r) => r?.orderId == orderId,
          orElse: () => null,
        );
    return AppResult.success(match);
  }

  @override
  Future<AppResult<List<ChatMessageModel>>> getMessages(String roomId) async {
    return AppResult.success(List.from(messages[roomId] ?? []));
  }

  @override
  Future<AppResult<ChatMessageModel>> sendMessage(
    String roomId,
    String message, {
    String? attachmentUrl,
  }) async {
    final newMsg = ChatMessageModel(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: 'user-me',
      senderName: 'Saya',
      message: message,
      isMe: true,
      isRead: false,
      createdAt: DateTime.now(),
      attachmentUrl: attachmentUrl,
    );
    if (!messages.containsKey(roomId)) {
      messages[roomId] = [];
    }
    messages[roomId]!.add(newMsg);
    return AppResult.success(newMsg);
  }

  @override
  Future<AppResult<bool>> markMessagesAsRead(String roomId) async {
    final idx = rooms.indexWhere((r) => r.id == roomId);
    if (idx != -1) {
      rooms[idx] = rooms[idx].copyWith(unreadCount: 0);
    }
    return AppResult.success(true);
  }
}

void main() {
  group('Chat Models Unit Tests', () {
    test('ChatMessageModel serialization and copyWith', () {
      final now = DateTime(2026, 10, 24, 12, 0);
      final json = {
        'id': 'msg-101',
        'room_id': 'room-1',
        'sender_id': 'user-123',
        'sender_name': 'Tester',
        'message': 'Halo dunia',
        'is_read': true,
        'created_at': now.toIso8601String(),
        'attachment_url': 'https://example.com/file.jpg',
      };

      final modelMe = ChatMessageModel.fromJson(json, currentUserId: 'user-123');
      expect(modelMe.id, 'msg-101');
      expect(modelMe.isMe, true);
      expect(modelMe.message, 'Halo dunia');
      expect(modelMe.attachmentUrl, 'https://example.com/file.jpg');

      final modelOther = ChatMessageModel.fromJson(json, currentUserId: 'other-user');
      expect(modelOther.isMe, false);

      final copy = modelMe.copyWith(isRead: false, message: 'Halo ubantu');
      expect(copy.isRead, false);
      expect(copy.message, 'Halo ubantu');
      expect(copy.id, modelMe.id);

      final map = modelMe.toJson();
      expect(map['id'], 'msg-101');
      expect(map['message'], 'Halo dunia');
    });

    test('ChatRoomModel serialization and copyWith', () {
      final now = DateTime(2026, 10, 24, 14, 0);
      final json = {
        'id': 'room-01',
        'order_id': 'order-01',
        'order_number': '#UB2026001',
        'service_title': 'Antar Barang',
        'service_status': 'SEDANG BERLANGSUNG',
        'other_user_name': 'Budi Santoso',
        'other_user_faculty': 'Teknik',
        'last_message': 'Siap mas',
        'last_message_time': now.toIso8601String(),
        'unread_count': 2,
        'is_active': true,
        'item_summary': 'Paket',
        'pickup_location': 'Gerbang UB',
        'destination_location': 'Griya UB',
        'total_price': 'Rp 50.000',
      };

      final room = ChatRoomModel.fromJson(json);
      expect(room.id, 'room-01');
      expect(room.orderNumber, '#UB2026001');
      expect(room.otherUserName, 'Budi Santoso');
      expect(room.unreadCount, 2);
      expect(room.isActive, true);

      final updated = room.copyWith(unreadCount: 0, lastMessage: 'Sudah selesai');
      expect(updated.unreadCount, 0);
      expect(updated.lastMessage, 'Sudah selesai');
      expect(updated.id, room.id);

      final map = room.toJson();
      expect(map['id'], 'room-01');
      expect(map['order_number'], '#UB2026001');
    });
  });

  group('Chat UseCases Unit Tests', () {
    late FakeChatRepository repo;

    setUp(() {
      repo = FakeChatRepository();
    });

    test('GetChatRoomsUseCase executes successfully', () async {
      final useCase = GetChatRoomsUseCase(repo);
      final result = await useCase.execute();

      expect(result.isSuccess, true);
      expect(result.data?.length, 2);
      expect(result.data?.first.otherUserName, 'Budi Santoso');
    });

    test('GetChatMessagesUseCase executes successfully', () async {
      final useCase = GetChatMessagesUseCase(repo);
      final result = await useCase.execute('room-test-1');

      expect(result.isSuccess, true);
      expect(result.data?.length, 2);
      expect(result.data?.first.message, 'Halo kak, saya sudah sampai di depan griya ya.');
    });

    test('SendChatMessageUseCase executes successfully', () async {
      final useCase = SendChatMessageUseCase(repo);
      final result = await useCase.execute('room-test-1', 'Halo saya segera kesana');

      expect(result.isSuccess, true);
      expect(result.data?.message, 'Halo saya segera kesana');
      expect(result.data?.isMe, true);
    });

    test('ChatRepositoryImpl returns clean empty rooms for new account', () async {
      final repo = ChatRepositoryImpl();
      final result = await repo.getChatRooms();
      expect(result.isSuccess, true);
      expect(result.data, isEmpty);
    });
  });

  group('ChatProvider State Management Tests', () {
    late FakeChatRepository repo;
    late ChatProvider provider;

    setUp(() {
      repo = FakeChatRepository();
      provider = ChatProvider(repository: repo);
    });

    test('loadRooms loads and exposes rooms', () async {
      await provider.loadRooms();
      expect(provider.rooms.length, 2);
      expect(provider.isLoadingRooms, false);
      expect(provider.rooms.first.otherUserName, 'Budi Santoso');
    });

    test('searchRooms filters correctly by name, service, or message', () async {
      await provider.loadRooms();
      expect(provider.rooms.length, 2);

      provider.searchRooms('Putra');
      expect(provider.rooms.length, 1);
      expect(provider.rooms.first.otherUserName, 'Putra Budiman');

      provider.searchRooms('UB2026001');
      expect(provider.rooms.length, 1);
      expect(provider.rooms.first.orderNumber, '#UB2026001');

      provider.searchRooms('tidak ada hasil');
      expect(provider.rooms.isEmpty, true);

      provider.searchRooms('');
      expect(provider.rooms.length, 2);
    });

    test('setActiveRoom loads room messages and marks as read', () async {
      await provider.loadRooms();
      final target = provider.rooms.first;

      provider.setActiveRoom(target);
      expect(provider.activeRoom?.id, target.id);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.activeMessages.length, 2);
    });

    test('sendMessage appends new message and updates last message preview', () async {
      await provider.loadRooms();
      final target = provider.rooms.first;
      provider.setActiveRoom(target);
      await provider.loadMessages(target.id);

      final success = await provider.sendMessage(target.id, 'Pesan uji coba');
      expect(success, true);
      expect(provider.activeMessages.last.message, 'Pesan uji coba');
      expect(provider.rooms.first.lastMessage, 'Pesan uji coba');
    });

    test('selectOrCreateRoomForOrder returns existing room or creates new one', () async {
      await provider.loadRooms();

      final existing = await provider.selectOrCreateRoomForOrder(
        orderId: 'order-test-1',
        orderNumber: '#UB2026001',
        serviceTitle: 'Antar Barang',
        otherUserName: 'Budi Santoso',
      );
      expect(existing?.id, 'room-test-1');

      final created = await provider.selectOrCreateRoomForOrder(
        orderId: 'order-new-99',
        orderNumber: '#UB2026099',
        serviceTitle: 'Pindah Kos',
        otherUserName: 'Mahasiswa Baru',
        pickupLocation: 'Asrama UB',
        destinationLocation: 'Kost Sigura-gura',
      );
      expect(created?.id, 'order-new-99');
      expect(created?.otherUserName, 'Mahasiswa Baru');
      expect(provider.activeRoom?.id, 'order-new-99');
    });
  });

  group('Chat Widget Tests', () {
    late FakeChatRepository repo;
    late ChatProvider chatProvider;

    setUp(() {
      repo = FakeChatRepository();
      chatProvider = ChatProvider(repository: repo);
    });

    Widget createWidgetUnderTest(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ChatProvider>.value(value: chatProvider),
          ChangeNotifierProvider(create: (_) => SosProvider()),
          ChangeNotifierProvider(create: (_) => RatingProvider()),
        ],
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('InboxView renders header, banner notice, search bar, and conversation items',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const InboxView()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Chat'), findsOneWidget);
      expect(
        find.text('Chat hanya tersedia untuk pesanan yang telah dikonfirmasi.'),
        findsOneWidget,
      );
      expect(find.text('Cari Percakapan'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Putra Budiman'), findsOneWidget);
      expect(find.text('Baik mas, ditunggu yaa'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Putra');
      await tester.pump();

      expect(find.text('Putra Budiman'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsNothing);
    });

    testWidgets('InboxView renders empty state when user has no conversation history',
        (tester) async {
      repo.rooms.clear();
      await tester.pumpWidget(createWidgetUnderTest(const InboxView()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Belum ada percakapan'), findsOneWidget);
    });

    testWidgets('ChatRoomView renders active order card, route, messages, and input',
        (tester) async {
      final activeRoom = repo.rooms.first;
      chatProvider.setActiveRoom(activeRoom);
      await chatProvider.loadMessages(activeRoom.id);

      await tester.pumpWidget(
        createWidgetUnderTest(
          ChatRoomView(initialRoom: activeRoom),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('SEDANG BERLANGSUNG'), findsOneWidget);
      expect(find.text('#UB2026001'), findsOneWidget);
      expect(find.text('Mall Olympic Garden'), findsOneWidget);
      expect(find.text('Kost Griya Mahasiswa'), findsOneWidget);
      expect(find.text('Halo kak, saya sudah sampai di depan griya ya.'), findsOneWidget);
      expect(find.text('Tulis Pesan...'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Saya otw turun ya!');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Saya otw turun ya!'), findsOneWidget);
    });

    testWidgets('ChatRoomView renders completed order card with rating button and countdown',
        (tester) async {
      final closedRoom = repo.rooms[1];
      chatProvider.setActiveRoom(closedRoom);
      await chatProvider.loadMessages(closedRoom.id);

      await tester.pumpWidget(
        createWidgetUnderTest(
          ChatRoomView(initialRoom: closedRoom),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Pengiriman berhasil diselesaikan.'), findsOneWidget);
      expect(find.text('Beri Penilaian'), findsOneWidget);
      expect(find.text('Lihat Detail Pesanan'), findsOneWidget);
      expect(find.text('Chat ditutup secara otomatis dalam 23.59'), findsOneWidget);

      await tester.tap(find.text('Beri Penilaian'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Beri Penilaian Layanan'), findsOneWidget);
    });

    testWidgets('ChatRoomView hides order summary card when keyboard is open',
        (tester) async {
      final closedRoom = repo.rooms[1];
      chatProvider.setActiveRoom(closedRoom);
      await chatProvider.loadMessages(closedRoom.id);

      await tester.pumpWidget(
        createWidgetUnderTest(
          MediaQuery(
            data: const MediaQueryData(
              viewInsets: EdgeInsets.only(bottom: 300),
            ),
            child: ChatRoomView(initialRoom: closedRoom),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Beri Penilaian'), findsNothing);
      expect(find.text('Lihat Detail Pesanan'), findsNothing);
    });

    testWidgets('DebugFloatingMenu displays Fitur Chat group with both routes',
        (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          const Scaffold(
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
      await tester.pump();

      expect(find.text('Navigasi Debug'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Fitur Chat & Percakapan'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('Fitur Chat & Percakapan'), findsOneWidget);
      expect(find.text('1. Inbox Percakapan'), findsOneWidget);
      expect(find.text('2. Ruang Chat Interaktif'), findsOneWidget);
    });
  });
}
