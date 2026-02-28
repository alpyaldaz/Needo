import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_room_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatRoomIdLoaded extends ChatState {
  final String roomId;

  const ChatRoomIdLoaded({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}

class UserChatRoomsLoaded extends ChatState {
  final List<ChatRoomEntity> rooms;

  const UserChatRoomsLoaded({required this.rooms});

  @override
  List<Object?> get props => [rooms];
}
