class ChatRoomModel {
  final String id;
  final String orderId;
  final String orderNumber;
  final String serviceTitle;
  final String serviceStatus;
  final String otherUserName;
  final String? otherUserFaculty;
  final String? otherUserAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isActive;
  final DateTime? closedAt;
  final String itemSummary;
  final String pickupLocation;
  final String destinationLocation;
  final String? totalPrice;

  const ChatRoomModel({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.serviceTitle,
    required this.serviceStatus,
    required this.otherUserName,
    this.otherUserFaculty,
    this.otherUserAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isActive = true,
    this.closedAt,
    required this.itemSummary,
    required this.pickupLocation,
    required this.destinationLocation,
    this.totalPrice,
  });

  ChatRoomModel copyWith({
    String? id,
    String? orderId,
    String? orderNumber,
    String? serviceTitle,
    String? serviceStatus,
    String? otherUserName,
    String? otherUserFaculty,
    String? otherUserAvatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isActive,
    DateTime? closedAt,
    String? itemSummary,
    String? pickupLocation,
    String? destinationLocation,
    String? totalPrice,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      serviceStatus: serviceStatus ?? this.serviceStatus,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserFaculty: otherUserFaculty ?? this.otherUserFaculty,
      otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
      closedAt: closedAt ?? this.closedAt,
      itemSummary: itemSummary ?? this.itemSummary,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      orderNumber: json['order_number'] as String? ?? '#UB2026001',
      serviceTitle: json['service_title'] as String? ?? 'Antar Barang',
      serviceStatus: json['service_status'] as String? ?? 'SEDANG BERLANGSUNG',
      otherUserName: json['other_user_name'] as String? ?? '',
      otherUserFaculty: json['other_user_faculty'] as String?,
      otherUserAvatar: json['other_user_avatar'] as String?,
      lastMessage: json['last_message'] as String? ?? '',
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'] as String)
          : DateTime.now(),
      unreadCount: json['unread_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at'] as String) : null,
      itemSummary: json['item_summary'] as String? ?? '',
      pickupLocation: json['pickup_location'] as String? ?? '',
      destinationLocation: json['destination_location'] as String? ?? '',
      totalPrice: json['total_price'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'order_number': orderNumber,
      'service_title': serviceTitle,
      'service_status': serviceStatus,
      'other_user_name': otherUserName,
      'other_user_faculty': otherUserFaculty,
      'other_user_avatar': otherUserAvatar,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime.toIso8601String(),
      'unread_count': unreadCount,
      'is_active': isActive,
      'closed_at': closedAt?.toIso8601String(),
      'item_summary': itemSummary,
      'pickup_location': pickupLocation,
      'destination_location': destinationLocation,
      'total_price': totalPrice,
    };
  }
}
