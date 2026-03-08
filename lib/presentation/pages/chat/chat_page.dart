import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../../data/datasources/local/hive_local_datasource.dart';
import '../../../injection_container.dart' as di;

class ChatPage extends StatefulWidget {
  final String otherUserId;

  const ChatPage({super.key, required this.otherUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
      context
          .read<ChatBloc>()
          .add(LoadMessagesEvent(_currentUserId, widget.otherUserId));
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatBloc>().add(SendMessageEvent(
          currentUserId: _currentUserId,
          otherUserId: widget.otherUserId,
          content: text,
        ));
    _msgController.clear();

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = di.sl<HiveLocalDatasource>();
    final otherUser = local.getUserById(widget.otherUserId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            if (otherUser != null)
              CircleAvatar(
                radius: 16,
                backgroundImage: otherUser.avatarUrl != null
                    ? NetworkImage(otherUser.avatarUrl!)
                    : null,
                child: otherUser.avatarUrl == null
                    ? const Icon(Icons.person, size: 20)
                    : null,
              ),
            const SizedBox(width: 10),
            Text(
              otherUser?.name ?? 'Người dùng',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
              icon: const Icon(Icons.call, color: AppTheme.primaryBlue),
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.videocam, color: AppTheme.primaryBlue),
              onPressed: () {}),
          IconButton(icon: const Icon(Icons.info), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatLoaded) {
                  final msgs = state.messages;
                  if (msgs.isEmpty) {
                    return const Center(
                      child: Text('Hãy gửi lời chào đầu tiên!',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }

                  // Auto scroll to latest on first load or new msg receipt
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController
                          .jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: msgs.length,
                    itemBuilder: (context, index) {
                      final msg = msgs[index];
                      final isMe = msg.senderId == _currentUserId;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? AppTheme.primaryBlue
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight:
                                  isMe ? const Radius.circular(0) : null,
                              bottomLeft:
                                  !isMe ? const Radius.circular(0) : null,
                            ),
                          ),
                          child: Text(
                            msg.content,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const Center(child: Text('Lỗi tải tin nhắn'));
              },
            ),
          ),

          // Chat Input
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppTheme.primaryBlue),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt,
                        color: AppTheme.primaryBlue),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo, color: AppTheme.primaryBlue),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Nhắn tin...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppTheme.primaryBlue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
