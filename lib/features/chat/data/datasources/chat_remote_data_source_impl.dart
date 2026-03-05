import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  @override
  Future<String> createOrGetChatRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    // Check if room exists where participants array contains both IDs
    // A more robust way is to query where participants array contains currentUserId,
    // and then filter in memory for otherUserId, OR use array-contains-any but that's limited.
    // The safest way is to generate a consistent room ID based on the two user IDs.

    final ids = [currentUserId, otherUserId];
    ids.sort(); // Sort to ensure consistent ID regardless of who creates it
    final roomId = '${ids[0]}_${ids[1]}';

    final roomRef = firestore.collection('chat_rooms').doc(roomId);
    final roomDoc = await roomRef.get();

    if (!roomDoc.exists) {
      // Create new room if it doesn't exist
      await roomRef.set({
        'id': roomId,
        'participants': [currentUserId, otherUserId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }

    return roomId;
  }

  @override
  Stream<List<ChatMessageModel>> getMessagesStream(String roomId) {
    return firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessageModel.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  @override
  Future<void> sendMessage(String roomId, ChatMessageModel message) async {
    final batch = firestore.batch();

    final roomRef = firestore.collection('chat_rooms').doc(roomId);
    final messagesRef = roomRef.collection('messages').doc(message.id);

    // 1. Add message
    final messageData = message.toJson();
    messageData['timestamp'] = FieldValue.serverTimestamp();
    batch.set(messagesRef, messageData);

    // 2. Update room's last message
    batch.update(roomRef, {
      'lastMessage': message.message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Stream<List<ChatRoomModel>> getUserChatRooms(String currentUserId) {
    return firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatRoomModel.fromJson(doc.data(), doc.id))
              .toList();
        });
  }
}
