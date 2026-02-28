import '../repositories/chat_repository.dart';

class CreateOrGetChatRoomUseCase {
  final ChatRepository repository;

  CreateOrGetChatRoomUseCase(this.repository);

  Future<String> call(String currentUserId, String otherUserId) async {
    return await repository.createOrGetChatRoom(currentUserId, otherUserId);
  }
}
