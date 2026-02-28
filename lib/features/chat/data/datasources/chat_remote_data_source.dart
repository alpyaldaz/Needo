import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';

abstract class ChatRemoteDataSource {
  Future<String> createOrGetChatRoom(String currentUserId, String otherUserId);
  Stream<List<ChatMessageModel>> getMessagesStream(String roomId);
  Future<void> sendMessage(String roomId, ChatMessageModel message);
  Stream<List<ChatRoomModel>> getUserChatRooms(String currentUserId);
}
