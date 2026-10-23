import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/chat_message_model.dart';
import 'package:ubantu/domain/models/chat_room_model.dart';

abstract class IChatRepository {
  Future<AppResult<List<ChatRoomModel>>> getChatRooms();
  Future<AppResult<ChatRoomModel?>> getChatRoomByOrderId(String orderId);
  Future<AppResult<List<ChatMessageModel>>> getMessages(String roomId);
  Future<AppResult<ChatMessageModel>> sendMessage(
    String roomId,
    String message, {
    String? attachmentUrl,
  });
  Future<AppResult<bool>> markMessagesAsRead(String roomId);
}
