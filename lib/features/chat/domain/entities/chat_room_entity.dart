import 'package:equatable/equatable.dart';

class ChatRoomEntity extends Equatable {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;

  const ChatRoomEntity({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  @override
  List<Object?> get props => [id, participants, lastMessage, lastMessageTime];
}
