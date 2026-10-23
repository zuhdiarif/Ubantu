class ChatMessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String message;
  final bool isMe;
  final bool isRead;
  final DateTime createdAt;
  final String? attachmentUrl;

  const ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.isMe,
    required this.isRead,
    required this.createdAt,
    this.attachmentUrl,
  });

  ChatMessageModel copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderName,
    String? message,
    bool? isMe,
    bool? isRead,
    DateTime? createdAt,
    String? attachmentUrl,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      message: message ?? this.message,
      isMe: isMe ?? this.isMe,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final senderId = json['sender_id'] as String? ?? '';
    final isMe = currentUserId != null ? senderId == currentUserId : (json['is_me'] as bool? ?? false);

    return ChatMessageModel(
      id: json['id'] as String? ?? '',
      roomId: json['room_id'] as String? ?? '',
      senderId: senderId,
      senderName: json['sender_name'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isMe: isMe,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      attachmentUrl: json['attachment_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'sender_name': senderName,
      'message': message,
      'is_me': isMe,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'attachment_url': attachmentUrl,
    };
  }
}
