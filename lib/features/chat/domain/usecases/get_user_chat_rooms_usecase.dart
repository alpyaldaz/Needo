import '../entities/chat_room_entity.dart';
import '../repositories/chat_repository.dart';

class GetUserChatRoomsUseCase {
  final ChatRepository repository;

  GetUserChatRoomsUseCase(this.repository);

  Stream<List<ChatRoomEntity>> call(String currentUserId) {
    return repository.getUserChatRooms(currentUserId);
  }
}
