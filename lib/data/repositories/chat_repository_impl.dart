import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/services/supabase_service.dart';
import 'package:ubantu/domain/models/chat_message_model.dart';
import 'package:ubantu/domain/models/chat_room_model.dart';
import 'package:ubantu/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements IChatRepository {
  final List<ChatRoomModel> _mockRooms = [
    ChatRoomModel(
      id: 'room-1',
      orderId: 'order-1',
      orderNumber: '#UB2026001',
      serviceTitle: 'Antar Barang',
      serviceStatus: 'SEDANG BERLANGSUNG',
      otherUserName: 'Budi Santoso',
      otherUserFaculty: 'Fakultas Teknik UB',
      lastMessage: 'Baik mas, ditunggu yaa',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      unreadCount: 1,
      isActive: true,
      itemSummary: 'Paket Dokumen & Alat Tulis',
      pickupLocation: 'Mall Olympic Garden',
      destinationLocation: 'Kost Griya Mahasiswa',
      totalPrice: 'Rp 65.000',
    ),
    ChatRoomModel(
      id: 'room-2',
      orderId: 'order-2',
      orderNumber: '#UB2026002',
      serviceTitle: 'Antar Barang',
      serviceStatus: 'SELESAI',
      otherUserName: 'Putra Budiman',
      otherUserFaculty: 'Fakultas Ilmu Komputer UB',
      lastMessage: 'Saya sudah sampai di lokasi kak',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isActive: false,
      closedAt: DateTime.now().subtract(const Duration(hours: 10)),
      itemSummary: 'Paket Dokumen & Alat Tulis',
      pickupLocation: 'Kost Griya Mahasiswa',
      destinationLocation: 'Kost Griya Mahasiswa',
      totalPrice: 'Rp 65.000',
    ),
    ChatRoomModel(
      id: 'room-3',
      orderId: 'order-3',
      orderNumber: '#UB2026003',
      serviceTitle: 'Pindah Kos',
      serviceStatus: 'SELESAI',
      otherUserName: 'Windah B.',
      otherUserFaculty: 'Fakultas Pertanian UB',
      lastMessage: 'Saya di depan lobby ya kak',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
      unreadCount: 0,
      isActive: false,
      closedAt: DateTime.now().subtract(const Duration(days: 2)),
      itemSummary: 'Bantu Angkut Lemari & Kasur',
      pickupLocation: 'Jl. MT Haryono Gang 4',
      destinationLocation: 'Jl. Sumbersari No. 12',
      totalPrice: 'Barter Barang',
    ),
  ];

  final Map<String, List<ChatMessageModel>> _mockMessages = {
    'room-1': [
      ChatMessageModel(
        id: 'msg-1',
        roomId: 'room-1',
        senderId: 'driver-1',
        senderName: 'Budi Santoso',
        message: 'Halo kak, saya sudah sampai di depan griya ya.',
        isMe: false,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 20)),
      ),
      ChatMessageModel(
        id: 'msg-2',
        roomId: 'room-1',
        senderId: 'user-me',
        senderName: 'Saya',
        message: 'Baik mas, tunggu sebentar ya saya turun dulu',
        isMe: true,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
      ),
      ChatMessageModel(
        id: 'msg-3',
        roomId: 'room-1',
        senderId: 'driver-1',
        senderName: 'Budi Santoso',
        message: 'Siap kak, saya tunggu dekat pos satpam ya',
        isMe: false,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ],
    'room-2': [
      ChatMessageModel(
        id: 'msg-201',
        roomId: 'room-2',
        senderId: 'driver-2',
        senderName: 'Putra Budiman',
        message: 'Halo kak, saya sudah sampai di depan griya ya.',
        isMe: false,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      ChatMessageModel(
        id: 'msg-202',
        roomId: 'room-2',
        senderId: 'user-me',
        senderName: 'Saya',
        message: 'Baik mas, tunggu sebentar ya saya turun dulu',
        isMe: true,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      ),
      ChatMessageModel(
        id: 'msg-203',
        roomId: 'room-2',
        senderId: 'driver-2',
        senderName: 'Putra Budiman',
        message: 'Siap kak, saya tunggu dekat pos satpam ya',
        isMe: false,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
    'room-3': [
      ChatMessageModel(
        id: 'msg-301',
        roomId: 'room-3',
        senderId: 'driver-3',
        senderName: 'Windah B.',
        message: 'Halo kak, posisi saya sudah jalan ke lokasi kos ya.',
        isMe: false,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ChatMessageModel(
        id: 'msg-302',
        roomId: 'room-3',
        senderId: 'driver-3',
        senderName: 'Windah B.',
        message: 'Saya di depan lobby ya kak',
        isMe: false,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3, minutes: -10)),
      ),
    ],
  };

  @override
  Future<AppResult<List<ChatRoomModel>>> getChatRooms() async {
    try {
      if (SupabaseService.instance.isInitialized) {
        final client = SupabaseService.instance.client;
        final currentUserId = client.auth.currentUser?.id;

        if (currentUserId != null) {
          final res = await client
              .from('chat_rooms')
              .select()
              .or('customer_id.eq.$currentUserId,helper_id.eq.$currentUserId')
              .order('updated_at', ascending: false);

          if (res.isNotEmpty) {
            final rooms = res.map((json) => ChatRoomModel.fromJson(json)).toList();
            return AppResult.success(rooms);
          }
        }
      }
      return AppResult.success(List.from(_mockRooms));
    } catch (_) {
      return AppResult.success(List.from(_mockRooms));
    }
  }

  @override
  Future<AppResult<ChatRoomModel?>> getChatRoomByOrderId(String orderId) async {
    try {
      final found = _mockRooms.cast<ChatRoomModel?>().firstWhere(
            (r) => r?.orderId == orderId,
            orElse: () => null,
          );
      return AppResult.success(found);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  @override
  Future<AppResult<List<ChatMessageModel>>> getMessages(String roomId) async {
    try {
      if (SupabaseService.instance.isInitialized) {
        final client = SupabaseService.instance.client;
        final currentUserId = client.auth.currentUser?.id;

        final res = await client
            .from('chat_messages')
            .select()
            .eq('room_id', roomId)
            .order('created_at', ascending: true);

        if (res.isNotEmpty) {
          final messages = res
              .map((json) => ChatMessageModel.fromJson(json, currentUserId: currentUserId))
              .toList();
          return AppResult.success(messages);
        }
      }

      final list = _mockMessages[roomId] ?? [];
      return AppResult.success(List.from(list));
    } catch (_) {
      final list = _mockMessages[roomId] ?? [];
      return AppResult.success(List.from(list));
    }
  }

  @override
  Future<AppResult<ChatMessageModel>> sendMessage(
    String roomId,
    String message, {
    String? attachmentUrl,
  }) async {
    try {
      final currentUserId = SupabaseService.instance.isInitialized
          ? SupabaseService.instance.client.auth.currentUser?.id ?? 'user-me'
          : 'user-me';

      final newMsg = ChatMessageModel(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        roomId: roomId,
        senderId: currentUserId,
        senderName: 'Saya',
        message: message,
        isMe: true,
        isRead: false,
        createdAt: DateTime.now(),
        attachmentUrl: attachmentUrl,
      );

      if (!_mockMessages.containsKey(roomId)) {
        _mockMessages[roomId] = [];
      }
      _mockMessages[roomId]!.add(newMsg);

      final roomIdx = _mockRooms.indexWhere((r) => r.id == roomId);
      if (roomIdx != -1) {
        _mockRooms[roomIdx] = _mockRooms[roomIdx].copyWith(
          lastMessage: message,
          lastMessageTime: DateTime.now(),
        );
      }

      if (SupabaseService.instance.isInitialized) {
        final client = SupabaseService.instance.client;
        await client.from('chat_messages').insert({
          'room_id': roomId,
          'sender_id': currentUserId,
          'sender_name': 'Saya',
          'message': message,
          'attachment_url': attachmentUrl,
          'is_read': false,
        });
      }

      return AppResult.success(newMsg);
    } catch (e) {
      final fallbackMsg = ChatMessageModel(
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
      if (!_mockMessages.containsKey(roomId)) {
        _mockMessages[roomId] = [];
      }
      _mockMessages[roomId]!.add(fallbackMsg);
      return AppResult.success(fallbackMsg);
    }
  }

  @override
  Future<AppResult<bool>> markMessagesAsRead(String roomId) async {
    try {
      final roomIdx = _mockRooms.indexWhere((r) => r.id == roomId);
      if (roomIdx != -1) {
        _mockRooms[roomIdx] = _mockRooms[roomIdx].copyWith(unreadCount: 0);
      }
      return AppResult.success(true);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }
}
