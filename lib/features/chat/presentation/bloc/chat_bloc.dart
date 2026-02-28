import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_or_get_chat_room_usecase.dart';
import '../../domain/usecases/get_user_chat_rooms_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final CreateOrGetChatRoomUseCase createOrGetChatRoomUseCase;
  final GetUserChatRoomsUseCase getUserChatRoomsUseCase;

  StreamSubscription? _chatRoomsSubscription;

  ChatBloc({
    required this.createOrGetChatRoomUseCase,
    required this.getUserChatRoomsUseCase,
  }) : super(ChatInitial()) {
    on<CreateRoomEvent>(_onCreateRoom);
    on<LoadUserChatRoomsEvent>(_onLoadUserChatRooms);
  }

  Future<void> _onCreateRoom(
    CreateRoomEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final roomId = await createOrGetChatRoomUseCase(
        event.currentUserId,
        event.otherUserId,
      );
      emit(ChatRoomIdLoaded(roomId: roomId));
    } catch (e) {
      emit(ChatError(message: 'Failed to create or get chat room: $e'));
    }
  }

  Future<void> _onLoadUserChatRooms(
    LoadUserChatRoomsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    await _chatRoomsSubscription?.cancel();

    try {
      await emit.forEach(
        getUserChatRoomsUseCase(event.currentUserId),
        onData: (rooms) => UserChatRoomsLoaded(rooms: rooms),
        onError: (error, stackTrace) => ChatError(message: error.toString()),
      );
    } catch (e) {
      emit(ChatError(message: 'Failed to load chat rooms: $e'));
    }
  }

  @override
  Future<void> close() {
    _chatRoomsSubscription?.cancel();
    return super.close();
  }
}
