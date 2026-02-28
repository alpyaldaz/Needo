import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> call(String roomId, ChatMessageEntity message) async {
    return await repository.sendMessage(roomId, message);
  }
}
