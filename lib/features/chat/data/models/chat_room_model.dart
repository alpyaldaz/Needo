import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_room_entity.dart';

class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required super.id,
    required super.participants,
    required super.lastMessage,
    required super.lastMessageTime,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json, String id) {
    return ChatRoomModel(
      id: id,
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage']?.toString() ?? '',
      lastMessageTime:
          (json['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
    };
  }

  factory ChatRoomModel.fromEntity(ChatRoomEntity entity) {
    return ChatRoomModel(
      id: entity.id,
      participants: entity.participants,
      lastMessage: entity.lastMessage,
      lastMessageTime: entity.lastMessageTime,
    );
  }
}
