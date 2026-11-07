import 'package:ubantu/core/errors/app_result.dart';
import 'package:ubantu/data/models/chat_room_model.dart';
import 'package:ubantu/data/repositories/chat_repository.dart';

class GetChatRoomsUseCase {
  final IChatRepository _repository;

  GetChatRoomsUseCase(this._repository);

  Future<AppResult<List<ChatRoomModel>>> execute() {
    return _repository.getChatRooms();
  }
}
