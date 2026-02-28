import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  const ChatMessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, senderId, receiverId, message, timestamp];
}
