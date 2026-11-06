import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubantu/components/photo_upload_card.dart';
import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/repositories/chat_repository_impl.dart';
import 'package:ubantu/data/services/supabase_storage_service.dart';
import 'package:ubantu/domain/models/chat_message_model.dart';
import 'package:ubantu/domain/models/chat_room_model.dart';
import 'package:ubantu/domain/repositories/chat_repository.dart';
import 'package:ubantu/domain/repositories/session_scoped.dart';
import 'package:ubantu/presentation/providers/chat_provider.dart';

class FakeFailingStorageService extends SupabaseStorageService {
  final String errorMessage;

  FakeFailingStorageService({
    this.errorMessage = 'Ukuran file maksimal 5 MB. Silakan pilih file yang lebih kecil.',
  });

  @override
  Future<AppResult<String>> uploadOrderPhoto(File file, String category) async {
    return AppResult.failure(errorMessage);
  }
}

class FakeThrowingStorageService extends SupabaseStorageService {
  @override
  Future<AppResult<String>> uploadOrderPhoto(File file, String category) async {
    throw Exception('Koneksi timeout saat mengunggah foto');
  }
}

class FakeSuccessStorageService extends SupabaseStorageService {
  final String remoteUrl;

  FakeSuccessStorageService({
    this.remoteUrl = 'https://supabase.co/storage/v1/object/public/order_photos/photo123.jpg',
  });

  @override
  Future<AppResult<String>> uploadOrderPhoto(File file, String category) async {
    return AppResult.success(remoteUrl);
  }
}

class FakeChatRepositoryForReset implements IChatRepository, SessionScoped {
  final List<ChatRoomModel> _rooms = [];
  final List<ChatMessageModel> _messages = [];
  bool clearCacheCalled = false;

  @override
  Future<AppResult<List<ChatRoomModel>>> getChatRooms() async => AppResult.success(List.from(_rooms));

  @override
  Future<AppResult<ChatRoomModel?>> getChatRoomByOrderId(String orderId) async => AppResult.success(null);

  @override
  Future<AppResult<List<ChatMessageModel>>> getMessages(String roomId) async => AppResult.success(List.from(_messages));

  @override
  Future<AppResult<ChatMessageModel>> sendMessage(String roomId, String message, {String? attachmentUrl}) async {
    final msg = ChatMessageModel(
      id: 'msg-1',
      roomId: roomId,
      senderId: 'user-me',
      senderName: 'Saya',
      message: message,
      isMe: true,
      isRead: false,
      createdAt: DateTime.now(),
    );
    _messages.add(msg);
    return AppResult.success(msg);
  }

  @override
  Future<AppResult<bool>> markMessagesAsRead(String roomId) async => AppResult.success(true);

  @override
  Stream<List<ChatMessageModel>> watchMessages(String roomId) => Stream.value(List.from(_messages));

  @override
  void clearSessionCache() {
    clearCacheCalled = true;
    _rooms.clear();
    _messages.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File dummyFile;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('upload_test_');
    dummyFile = File('${tempDir.path}/sample.jpg')..writeAsBytesSync([1, 2, 3, 4]);
  });

  tearDownAll(() {
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('PhotoUploadCard Regression Tests', () {
    testWidgets('upload failure does NOT call onPhotoChanged and shows red SnackBar', (tester) async {
      String? changedPhoto;
      bool onPhotoChangedInvoked = false;
      const expectedError = 'Ukuran file maksimal 5 MB. Silakan pilih file yang lebih kecil.';

      final storageService = FakeFailingStorageService(errorMessage: expectedError);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoUploadCard(
              currentPhotoUrl: null,
              storageService: storageService,
              onPhotoChanged: (val) {
                onPhotoChangedInvoked = true;
                changedPhoto = val;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      final state = tester.state<PhotoUploadCardState>(find.byType(PhotoUploadCard));
      await state.handleFileForTesting(dummyFile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(onPhotoChangedInvoked, false);
      expect(changedPhoto, isNull);
      expect(find.text(expectedError), findsOneWidget);

      final snackBarFinder = find.byType(SnackBar);
      expect(snackBarFinder, findsOneWidget);
      final snackBar = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBar.backgroundColor, Colors.red);
    });

    testWidgets('upload exception in catch block does NOT call onPhotoChanged and shows red SnackBar', (tester) async {
      String? changedPhoto;
      bool onPhotoChangedInvoked = false;

      final storageService = FakeThrowingStorageService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoUploadCard(
              currentPhotoUrl: null,
              storageService: storageService,
              onPhotoChanged: (val) {
                onPhotoChangedInvoked = true;
                changedPhoto = val;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      final state = tester.state<PhotoUploadCardState>(find.byType(PhotoUploadCard));
      await state.handleFileForTesting(dummyFile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(onPhotoChangedInvoked, false);
      expect(changedPhoto, isNull);
      expect(find.byType(SnackBar), findsOneWidget);
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red);
    });

    testWidgets('success path calls onPhotoChanged with remote URL and no error SnackBar', (tester) async {
      String? changedPhoto;
      bool onPhotoChangedInvoked = false;
      const expectedRemoteUrl = 'https://supabase.co/storage/v1/object/public/order_photos/photo123.jpg';

      final storageService = FakeSuccessStorageService(remoteUrl: expectedRemoteUrl);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoUploadCard(
              currentPhotoUrl: null,
              storageService: storageService,
              onPhotoChanged: (val) {
                onPhotoChangedInvoked = true;
                changedPhoto = val;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      final state = tester.state<PhotoUploadCardState>(find.byType(PhotoUploadCard));
      await state.handleFileForTesting(dummyFile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(onPhotoChangedInvoked, true);
      expect(changedPhoto, expectedRemoteUrl);
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('ChatRepositoryImpl Session & Regression Tests', () {
    test('ChatRepositoryImpl implements SessionScoped and clearSessionCache empties all in-memory state', () {
      final repo = ChatRepositoryImpl();
      expect(repo, isA<SessionScoped>());

      final testRoom = ChatRoomModel(
        id: 'test-room-1',
        orderId: 'test-order-1',
        orderNumber: '#UB-001',
        serviceTitle: 'Layanan Antar',
        serviceStatus: 'SEDANG BERLANGSUNG',
        otherUserName: 'Rian Pratama',
        lastMessage: 'Halo',
        lastMessageTime: DateTime.now(),
        unreadCount: 2,
        isActive: true,
        itemSummary: 'Paket makanan',
        pickupLocation: 'Kantin UB',
        destinationLocation: 'Kost Griya',
      );

      final testMsg = ChatMessageModel(
        id: 'msg-99',
        roomId: 'test-room-1',
        senderId: 'user-1',
        senderName: 'Rian Pratama',
        message: 'Halo',
        isMe: false,
        isRead: false,
        createdAt: DateTime.now(),
      );

      repo.seedMockRoomsForTesting([testRoom]);
      repo.seedMockMessagesForTesting('test-room-1', [testMsg]);

      expect(repo.getMockRoomsForTesting().length, 1);
      expect(repo.getMockMessagesForTesting('test-room-1').length, 1);

      repo.clearSessionCache();

      expect(repo.getMockRoomsForTesting(), isEmpty);
      expect(repo.getMockMessagesForTesting('test-room-1'), isEmpty);
    });

    test('ChatRepositoryImpl.getChatRooms returns clean empty list and does NOT inject fake Budi Santoso', () async {
      final repo = ChatRepositoryImpl();
      final result = await repo.getChatRooms();

      expect(result.isSuccess, true);
      expect(result.data, isEmpty);
      expect(result.data?.any((r) => r.otherUserName == 'Budi Santoso'), false);
    });
  });

  group('ChatProvider Session Reset Tests', () {
    test('resetSession clears per-user provider state and notifies listeners', () {
      final repo = FakeChatRepositoryForReset();
      final provider = ChatProvider(repository: repo);

      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      final dummyRoom = ChatRoomModel(
        id: 'room-1',
        orderId: 'order-1',
        orderNumber: '#UB-1',
        serviceTitle: 'Pindah Kos',
        serviceStatus: 'SEDANG BERLANGSUNG',
        otherUserName: 'Tester',
        lastMessage: 'Test message',
        lastMessageTime: DateTime.now(),
        unreadCount: 3,
        isActive: true,
        itemSummary: 'Lemari & Kasur',
        pickupLocation: 'Kost Veteran',
        destinationLocation: 'Kost Soehat',
      );

      provider.setActiveRoom(dummyRoom);
      expect(provider.activeRoom, isNotNull);

      provider.resetSession();

      expect(notified, true);
      expect(provider.activeRoom, isNull);
      expect(provider.rooms, isEmpty);
      expect(provider.activeMessages, isEmpty);
      expect(provider.hasUnreadMessages, false);
      expect(provider.totalUnreadCount, 0);
      expect(provider.searchQuery, isEmpty);
      expect(provider.isLoadingRooms, false);
      expect(provider.isLoadingMessages, false);
      expect(provider.isSendingMessage, false);
      expect(provider.errorMessage, isNull);
    });
  });
}
