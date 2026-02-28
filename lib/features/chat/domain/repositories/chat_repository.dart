import '../entities/chat_message_entity.dart';
import '../entities/chat_room_entity.dart';

abstract class ChatRepository {
  Future<String> createOrGetChatRoom(String currentUserId, String otherUserId);
  Stream<List<ChatMessageEntity>> getMessagesStream(String roomId);
  Future<void> sendMessage(String roomId, ChatMessageEntity message);
  Stream<List<ChatRoomEntity>> getUserChatRooms(String currentUserId);
}
