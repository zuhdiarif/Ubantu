import 'package:flutter/material.dart';
import 'package:ubantu/data/repositories/chat_repository_impl.dart';
import 'package:ubantu/domain/models/chat_message_model.dart';
import 'package:ubantu/domain/models/chat_room_model.dart';
import 'package:ubantu/domain/repositories/chat_repository.dart';
import 'package:ubantu/domain/usecases/get_chat_messages_usecase.dart';
import 'package:ubantu/domain/usecases/get_chat_rooms_usecase.dart';
import 'package:ubantu/domain/usecases/send_chat_message_usecase.dart';

class ChatProvider extends ChangeNotifier {
  final IChatRepository _repository;
  final GetChatRoomsUseCase _getChatRoomsUseCase;
  final GetChatMessagesUseCase _getChatMessagesUseCase;
  final SendChatMessageUseCase _sendChatMessageUseCase;

  ChatProvider({IChatRepository? repository})
      : _repository = repository ?? ChatRepositoryImpl(),
        _getChatRoomsUseCase = GetChatRoomsUseCase(repository ?? ChatRepositoryImpl()),
        _getChatMessagesUseCase = GetChatMessagesUseCase(repository ?? ChatRepositoryImpl()),
        _sendChatMessageUseCase = SendChatMessageUseCase(repository ?? ChatRepositoryImpl());

  List<ChatRoomModel> _rooms = [];
  List<ChatRoomModel> _filteredRooms = [];
  String _searchQuery = '';
  ChatRoomModel? _activeRoom;
  List<ChatMessageModel> _activeMessages = [];
  bool _isLoadingRooms = false;
  bool _isLoadingMessages = false;
  bool _isSendingMessage = false;
  String? _errorMessage;

  List<ChatRoomModel> get rooms => _searchQuery.isEmpty ? List.unmodifiable(_rooms) : List.unmodifiable(_filteredRooms);
  ChatRoomModel? get activeRoom => _activeRoom;
  List<ChatMessageModel> get activeMessages => List.unmodifiable(_activeMessages);
  bool get isLoadingRooms => _isLoadingRooms;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSendingMessage => _isSendingMessage;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get hasUnreadMessages => _rooms.any((room) => room.unreadCount > 0);
  int get totalUnreadCount => _rooms.fold(0, (sum, room) => sum + room.unreadCount);

  Future<void> loadRooms({bool isPolling = false}) async {
    if (!isPolling) {
      _isLoadingRooms = true;
      _errorMessage = null;
      notifyListeners();
    }

    final result = await _getChatRoomsUseCase.execute();
    if (result.isSuccess && result.data != null) {
      _rooms = result.data!;
      _applySearch();
    } else if (!isPolling) {
      _errorMessage = result.errorMessage;
    }

    if (!isPolling) {
      _isLoadingRooms = false;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void searchRooms(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredRooms = List.from(_rooms);
    } else {
      _filteredRooms = _rooms.where((room) {
        final nameMatch = room.otherUserName.toLowerCase().contains(_searchQuery);
        final orderMatch = room.orderNumber.toLowerCase().contains(_searchQuery);
        final serviceMatch = room.serviceTitle.toLowerCase().contains(_searchQuery);
        final lastMsgMatch = room.lastMessage.toLowerCase().contains(_searchQuery);
        return nameMatch || orderMatch || serviceMatch || lastMsgMatch;
      }).toList();
    }
  }

  void setActiveRoom(ChatRoomModel room) {
    _activeRoom = room;
    notifyListeners();
    loadMessages(room.id);
    markAsRead(room.id);
  }

  Future<void> loadMessages(String roomId, {bool isPolling = false}) async {
    if (!isPolling) {
      _isLoadingMessages = true;
      _errorMessage = null;
      notifyListeners();
    }

    final result = await _getChatMessagesUseCase.execute(roomId);
    if (result.isSuccess && result.data != null) {
      _activeMessages = result.data!;
    } else if (!isPolling) {
      _errorMessage = result.errorMessage;
    }

    if (!isPolling) {
      _isLoadingMessages = false;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String roomId, String text, {String? attachmentUrl}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty && attachmentUrl == null) return false;

    _isSendingMessage = true;
    notifyListeners();

    final result = await _sendChatMessageUseCase.execute(
      roomId,
      cleanText,
      attachmentUrl: attachmentUrl,
    );

    _isSendingMessage = false;

    if (result.isSuccess && result.data != null) {
      final sentMsg = result.data!;
      if (!_activeMessages.any((m) => m.id == sentMsg.id)) {
        _activeMessages.add(sentMsg);
      }
      final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
      if (roomIndex != -1) {
        _rooms[roomIndex] = _rooms[roomIndex].copyWith(
          lastMessage: cleanText,
          lastMessageTime: sentMsg.createdAt,
        );
        _applySearch();
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<void> markAsRead(String roomId) async {
    await _repository.markMessagesAsRead(roomId);
    final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex != -1) {
      _rooms[roomIndex] = _rooms[roomIndex].copyWith(unreadCount: 0);
      _applySearch();
      notifyListeners();
    }
  }

  Future<ChatRoomModel?> selectOrCreateRoomForOrder({
    required String orderId,
    required String orderNumber,
    required String serviceTitle,
    required String otherUserName,
    String? otherUserFaculty,
    String? itemSummary,
    String? pickupLocation,
    String? destinationLocation,
    String? totalPrice,
    bool isActive = true,
  }) async {
    final existing = _rooms.cast<ChatRoomModel?>().firstWhere(
          (r) => r?.orderId == orderId || r?.id == orderId,
          orElse: () => null,
        );

    if (existing != null) {
      setActiveRoom(existing);
      return existing;
    }

    final newRoom = ChatRoomModel(
      id: orderId,
      orderId: orderId,
      orderNumber: orderNumber,
      serviceTitle: serviceTitle,
      serviceStatus: isActive ? 'SEDANG BERLANGSUNG' : 'SELESAI',
      otherUserName: otherUserName,
      otherUserFaculty: otherUserFaculty ?? 'Mahasiswa UB',
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isActive: isActive,
      itemSummary: itemSummary ?? 'Layanan $serviceTitle',
      pickupLocation: pickupLocation ?? 'Universitas Brawijaya',
      destinationLocation: destinationLocation ?? 'Kost Mahasiswa',
      totalPrice: totalPrice ?? 'Barter',
    );

    _rooms.insert(0, newRoom);
    _applySearch();
    setActiveRoom(newRoom);
    return newRoom;
  }
}
