import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../models/chat_message_model.dart';
import '../datasources/chat_remote_data_source.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> createOrGetChatRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    return await remoteDataSource.createOrGetChatRoom(
      currentUserId,
      otherUserId,
    );
  }

  @override
  Stream<List<ChatMessageEntity>> getMessagesStream(String roomId) {
    return remoteDataSource.getMessagesStream(roomId);
  }

  @override
  Future<void> sendMessage(String roomId, ChatMessageEntity message) async {
    final messageModel = ChatMessageModel.fromEntity(message);
    await remoteDataSource.sendMessage(roomId, messageModel);
  }

  @override
  Stream<List<ChatRoomEntity>> getUserChatRooms(String currentUserId) {
    return remoteDataSource.getUserChatRooms(currentUserId);
  }
}
