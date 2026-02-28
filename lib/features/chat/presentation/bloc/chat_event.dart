import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class CreateRoomEvent extends ChatEvent {
  final String currentUserId;
  final String otherUserId;

  const CreateRoomEvent({
    required this.currentUserId,
    required this.otherUserId,
  });

  @override
  List<Object?> get props => [currentUserId, otherUserId];
}

class LoadUserChatRoomsEvent extends ChatEvent {
  final String currentUserId;

  const LoadUserChatRoomsEvent({required this.currentUserId});

  @override
  List<Object?> get props => [currentUserId];
}
