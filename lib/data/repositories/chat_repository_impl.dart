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

        final List<ChatRoomModel> resultRooms = [];

        try {
          final ordersRes = await client
              .from('service_orders')
              .select()
              .order('created_at', ascending: false);

          for (final order in ordersRes) {
            final orderId = order['id'] as String;
            final roomId = 'room_$orderId';

            String lastMsg = '';
            DateTime lastTime = DateTime.tryParse(order['created_at']?.toString() ?? '') ?? DateTime.now();
            int unread = 0;

            try {
              final msgsRes = await client
                  .from('chat_messages')
                  .select()
                  .eq('room_id', roomId)
                  .order('created_at', ascending: false);

              if (msgsRes.isNotEmpty) {
                lastMsg = msgsRes.first['message'] as String? ?? '';
                lastTime = DateTime.tryParse(msgsRes.first['created_at']?.toString() ?? '') ?? lastTime;
                unread = msgsRes
                    .where((m) => m['sender_id'] != currentUserId && m['is_read'] == false)
                    .length;
              }
            } catch (_) {}

            final isRequester = currentUserId != null ? order['requester_id'] == currentUserId : true;
            final otherName = isRequester
                ? (order['helper_id'] != null ? 'Nasya (Mitra UB)' : 'Menunggu Petugas')
                : 'Mahasiswa UB (Pemesan)';

            final statusStr = order['status']?.toString() ?? '';
            final isCompleted = statusStr == 'completed';
            final isActive = !isCompleted && statusStr != 'cancelled';

            final category = order['category']?.toString() ?? 'bantuan';
            final categoryDisplay = switch (category) {
              'pindahKos' => 'Pindah Kos',
              'bersihKos' => 'Bersih Kos',
              'antarJemput' => 'Antar Jemput',
              _ => category,
            };

            resultRooms.add(
              ChatRoomModel(
                id: roomId,
                orderId: orderId,
                orderNumber: '#UB-${orderId.length > 4 ? orderId.substring(0, 4).toUpperCase() : '8890'}',
                serviceTitle: 'Layanan $categoryDisplay',
                serviceStatus: isCompleted ? 'SELESAI' : 'SEDANG BERLANGSUNG',
                otherUserName: otherName,
                otherUserFaculty: 'Universitas Brawijaya',
                lastMessage: lastMsg.isNotEmpty ? lastMsg : 'Mulai percakapan order',
                lastMessageTime: lastTime,
                unreadCount: unread,
                isActive: isActive,
                itemSummary: order['item_description']?.toString() ?? 'Layanan Ubantu',
                pickupLocation: order['location_origin']?.toString() ?? 'Universitas Brawijaya',
                destinationLocation: order['location_destination']?.toString() ?? 'Kost Mahasiswa',
                totalPrice: order['barter_description']?.toString() ?? 'Barter',
              ),
            );
          }
        } catch (_) {}

        try {
          final res = await client
              .from('chat_rooms')
              .select()
              .order('updated_at', ascending: false);

          for (final json in res) {
            final room = ChatRoomModel.fromJson(json);
            if (!resultRooms.any((r) => r.id == room.id)) {
              resultRooms.add(room);
            }
          }
        } catch (_) {}

        if (resultRooms.isNotEmpty) {
          for (final r in resultRooms) {
            final idx = _mockRooms.indexWhere((m) => m.id == r.id);
            if (idx != -1) {
              _mockRooms[idx] = r;
            } else {
              _mockRooms.insert(0, r);
            }
          }
          return AppResult.success(resultRooms);
        }
      }
      return AppResult.success(List.from(_mockRooms));
    } catch (_) {
      return AppResult.success(List.from(_mockRooms));
    }
  }

  bool _isValidUuid(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(value);
  }

  Future<void> _ensureRoomExists(String roomId) async {
    if (!SupabaseService.instance.isInitialized) return;
    final client = SupabaseService.instance.client;
    final currentUserId = client.auth.currentUser?.id;
    if (currentUserId == null) return;

    try {
      final existing = await client
          .from('chat_rooms')
          .select('id, customer_id, helper_id')
          .eq('id', roomId)
          .maybeSingle();

      if (existing != null) {
        final existingHelperId = existing['helper_id'] as String?;
        final existingCustomerId = existing['customer_id'] as String?;
        if (existingHelperId == null && currentUserId != existingCustomerId) {
          await client
              .from('chat_rooms')
              .update({'helper_id': currentUserId})
              .eq('id', roomId);
        }
        return;
      }

      String customerId = currentUserId;
      String? helperId;
      String orderNumber = '#UB-${roomId.length > 4 ? roomId.substring(0, 4).toUpperCase() : '8890'}';
      String serviceTitle = 'Layanan Ubantu';
      String itemSummary = 'Layanan Ubantu';
      String pickupLocation = 'Universitas Brawijaya';
      String destinationLocation = 'Kost Mahasiswa';

      try {
        final orderData = await client
            .from('service_orders')
            .select()
            .eq('id', roomId)
            .maybeSingle();

        if (orderData != null) {
          final reqId = orderData['requester_id'] as String?;
          final hlpId = orderData['helper_id'] as String?;
          if (reqId != null && reqId.isNotEmpty) {
            customerId = reqId;
          }
          if (hlpId != null && hlpId.isNotEmpty && _isValidUuid(hlpId)) {
            helperId = hlpId;
          } else if (currentUserId != customerId) {
            helperId = currentUserId;
          }
          final cat = orderData['category']?.toString() ?? 'bantuan';
          serviceTitle = 'Layanan ${cat == 'pindahKos' ? 'Pindah Kos' : (cat == 'bersihKos' ? 'Bersih Kos' : 'Antar Jemput')}';
          itemSummary = orderData['item_description']?.toString() ?? itemSummary;
          pickupLocation = orderData['location_origin']?.toString() ?? pickupLocation;
          destinationLocation = orderData['location_destination']?.toString() ?? destinationLocation;
        }
      } catch (_) {}

      await client.from('chat_rooms').upsert({
        'id': roomId,
        'customer_id': customerId,
        'helper_id': helperId,
        'order_number': orderNumber,
        'service_title': serviceTitle,
        'service_status': 'in_progress',
        'is_active': true,
        'item_summary': itemSummary,
        'pickup_location': pickupLocation,
        'destination_location': destinationLocation,
      });
    } catch (_) {}
  }

  @override
  Future<AppResult<ChatRoomModel?>> getChatRoomByOrderId(String orderId) async {
    try {
      final found = _mockRooms.cast<ChatRoomModel?>().firstWhere(
            (r) => r?.orderId == orderId || r?.id == orderId,
            orElse: () => null,
          );
      if (found != null) {
        return AppResult.success(found);
      }

      if (SupabaseService.instance.isInitialized && _isValidUuid(orderId)) {
        final client = SupabaseService.instance.client;
        final res = await client
            .from('chat_rooms')
            .select()
            .eq('id', orderId)
            .maybeSingle();

        if (res != null) {
          final room = ChatRoomModel.fromJson(res);
          return AppResult.success(room);
        }
      }

      return AppResult.success(null);
    } catch (e) {
      return AppResult.failure(e.toString());
    }
  }

  @override
  Future<AppResult<List<ChatMessageModel>>> getMessages(String roomId) async {
    try {
      if (SupabaseService.instance.isInitialized && _isValidUuid(roomId)) {
        final client = SupabaseService.instance.client;
        final currentUserId = client.auth.currentUser?.id;

        final res = await client
            .from('chat_messages')
            .select()
            .eq('room_id', roomId)
            .order('created_at', ascending: true);

        final messages = res
            .map((json) => ChatMessageModel.fromJson(json, currentUserId: currentUserId))
            .toList();
        _mockMessages[roomId] = messages;
        return AppResult.success(messages);
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

      final userMeta = SupabaseService.instance.isInitialized
          ? SupabaseService.instance.client.auth.currentUser?.userMetadata
          : null;
      final senderName = (userMeta?['full_name'] as String?)?.isNotEmpty == true
          ? userMeta!['full_name'] as String
          : 'Saya';

      if (SupabaseService.instance.isInitialized && _isValidUuid(roomId)) {
        await _ensureRoomExists(roomId);

        final client = SupabaseService.instance.client;
        final insertRes = await client.from('chat_messages').insert({
          'room_id': roomId,
          'sender_id': currentUserId,
          'sender_name': senderName,
          'message': message,
          'attachment_url': attachmentUrl,
          'is_read': false,
        }).select().single();

        final sentMsg = ChatMessageModel.fromJson(insertRes, currentUserId: currentUserId);

        if (!_mockMessages.containsKey(roomId)) {
          _mockMessages[roomId] = [];
        }
        if (!_mockMessages[roomId]!.any((m) => m.id == sentMsg.id)) {
          _mockMessages[roomId]!.add(sentMsg);
        }

        final roomIdx = _mockRooms.indexWhere((r) => r.id == roomId);
        if (roomIdx != -1) {
          _mockRooms[roomIdx] = _mockRooms[roomIdx].copyWith(
            lastMessage: message,
            lastMessageTime: sentMsg.createdAt,
          );
        }

        return AppResult.success(sentMsg);
      }

      final fallbackMsg = ChatMessageModel(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        roomId: roomId,
        senderId: currentUserId,
        senderName: senderName,
        message: message,
        isMe: true,
        isRead: false,
        createdAt: DateTime.now(),
        attachmentUrl: attachmentUrl,
      );

      if (!_mockMessages.containsKey(roomId)) {
        _mockMessages[roomId] = [];
      }
      if (!_mockMessages[roomId]!.any((m) => m.id == fallbackMsg.id)) {
        _mockMessages[roomId]!.add(fallbackMsg);
      }

      final roomIdx = _mockRooms.indexWhere((r) => r.id == roomId);
      if (roomIdx != -1) {
        _mockRooms[roomIdx] = _mockRooms[roomIdx].copyWith(
          lastMessage: message,
          lastMessageTime: DateTime.now(),
        );
      }

      return AppResult.success(fallbackMsg);
    } catch (_) {
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
      if (!_mockMessages[roomId]!.any((m) => m.id == fallbackMsg.id)) {
        _mockMessages[roomId]!.add(fallbackMsg);
      }

      return AppResult.success(fallbackMsg);
    }
  }

  @override
  Future<AppResult<bool>> markMessagesAsRead(String roomId) async {
    try {
      final currentUserId = SupabaseService.instance.isInitialized
          ? SupabaseService.instance.client.auth.currentUser?.id
          : null;

      if (SupabaseService.instance.isInitialized && currentUserId != null && _isValidUuid(roomId)) {
        final client = SupabaseService.instance.client;
        try {
          await client
              .from('chat_messages')
              .update({'is_read': true})
              .eq('room_id', roomId)
              .neq('sender_id', currentUserId);
        } catch (_) {}
      }

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
