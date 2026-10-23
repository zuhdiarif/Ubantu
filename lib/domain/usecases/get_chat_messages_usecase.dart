import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/domain/models/chat_message_model.dart';
import 'package:ubantu/domain/repositories/chat_repository.dart';

class GetChatMessagesUseCase {
  final IChatRepository _repository;

  GetChatMessagesUseCase(this._repository);

  Future<AppResult<List<ChatMessageModel>>> execute(String roomId) {
    return _repository.getMessages(roomId);
  }
}
