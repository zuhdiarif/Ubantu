import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/chat_message_model.dart';
import 'package:ubantu/domain/repositories/chat_repository.dart';

class SendChatMessageUseCase {
  final IChatRepository _repository;

  SendChatMessageUseCase(this._repository);

  Future<AppResult<ChatMessageModel>> execute(
    String roomId,
    String message, {
    String? attachmentUrl,
  }) {
    return _repository.sendMessage(roomId, message, attachmentUrl: attachmentUrl);
  }
}
