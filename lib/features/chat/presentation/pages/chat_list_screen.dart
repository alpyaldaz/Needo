import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:needo/config/routes.dart';
import 'package:needo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:needo/features/auth/presentation/bloc/auth_state.dart';
import 'package:needo/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:needo/features/chat/presentation/bloc/chat_event.dart';
import 'package:needo/features/chat/presentation/bloc/chat_state.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // Cache fetched names so we don't re-fetch on every rebuild
  final Map<String, String> _userNameCache = {};

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  void _loadChatRooms() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ChatBloc>().add(
        LoadUserChatRoomsEvent(currentUserId: authState.user.id),
      );
    }
  }

  Future<String> _fetchUserName(String userId) async {
    if (_userNameCache.containsKey(userId)) {
      return _userNameCache[userId]!;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final firstName = data['firstName'] as String? ?? '';
        final lastName = data['lastName'] as String? ?? '';
        final name = '$firstName $lastName'.trim();
        final displayName = name.isNotEmpty
            ? name
            : (data['name'] as String? ?? 'User');
        _userNameCache[userId] = displayName;
        return displayName;
      }
    } catch (_) {}
    return 'User';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final localTime = time.toLocal();
    final difference = now.difference(localTime);

    if (difference.inDays == 0 && now.day == localTime.day) {
      return DateFormat('HH:mm').format(localTime);
    } else if (difference.inDays == 1 ||
        (difference.inDays == 0 && now.day != localTime.day)) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(localTime);
    } else {
      return DateFormat('MMM d, yyyy').format(localTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthAuthenticated) {
            _loadChatRooms();
          }
        },
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: Text("Please login first"));
          }
          final currentUser = authState.user;

          return BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (previous, current) {
              return current is UserChatRoomsLoaded ||
                  current is ChatLoading ||
                  current is ChatError;
            },
            builder: (context, chatState) {
              if (chatState is UserChatRoomsLoaded) {
                final rooms = chatState.rooms;

                if (rooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start connecting with others!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: rooms.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    // Find the OTHER participant's ID
                    final otherUserId = room.participants.firstWhere(
                      (id) => id != currentUser.id,
                      orElse: () => 'Unknown',
                    );

                    return FutureBuilder<String>(
                      future: _fetchUserName(otherUserId),
                      builder: (context, snapshot) {
                        final displayName = snapshot.data ?? 'User';
                        final initial = displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          tileColor: Colors.white,
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(
                              0xFFACC8A2,
                            ).withValues(alpha: 0.1),
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Color(0xFFACC8A2),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          title: Text(
                            displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            room.lastMessage.isNotEmpty
                                ? room.lastMessage
                                : 'Say hello...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          trailing: Text(
                            _formatTime(room.lastMessageTime),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.chat,
                              arguments: {
                                'roomId': room.id,
                                'currentUserId': currentUser.id,
                                'otherUserName': displayName,
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              } else if (chatState is ChatError) {
                return Center(child: Text(chatState.message));
              }

              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }
}
