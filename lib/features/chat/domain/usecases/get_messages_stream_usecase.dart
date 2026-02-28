import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesStreamUseCase {
  final ChatRepository repository;

  GetMessagesStreamUseCase(this.repository);

  Stream<List<ChatMessageEntity>> call(String roomId) {
    return repository.getMessagesStream(roomId);
  }
}
