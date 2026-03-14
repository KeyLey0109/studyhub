import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../../data/datasources/local/hive_local_datasource.dart';
import '../../../injection_container.dart' as di;
import '../../widgets/common/avatar_widget.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../data/datasources/remote/supabase_remote_datasource.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;

  const ChatPage({super.key, required this.otherUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  late String _currentUserId;
  Timer? _refreshTimer;
  UserEntity? _otherUser;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
      _loadOtherUserInfo();
      _loadMessages();

      _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _loadMessages();
      });
    }
  }

  void _loadMessages() {
    context.read<ChatBloc>().add(LoadMessagesEvent(_currentUserId, widget.otherUserId));
  }

  Future<void> _loadOtherUserInfo() async {
    final local = di.sl<HiveLocalDatasource>();
    final user = local.getUserById(widget.otherUserId);
    if (user != null) {
      setState(() => _otherUser = user);
    } else {
      try {
        final remote = di.sl<SupabaseRemoteDatasource>();
        final fetchedUser = await remote.getUserById(widget.otherUserId);
        if (fetchedUser != null) {
          await local.saveUser(fetchedUser);
          if (mounted) setState(() => _otherUser = fetchedUser);
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
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
    _scrollToBottom();
  }

  Future<void> _pickMedia(bool isVideo, {bool fromCamera = false}) async {
    final XFile? file = isVideo 
      ? await _picker.pickVideo(source: fromCamera ? ImageSource.camera : ImageSource.gallery)
      : await _picker.pickImage(source: fromCamera ? ImageSource.camera : ImageSource.gallery, imageQuality: 70);

    if (file != null) {
      if (kIsWeb) {
        // Xử lý đặc biệt cho Web: lấy bytes và tải lên trực tiếp
        final bytes = await file.readAsBytes();
        final ext = file.name.split('.').last.toLowerCase();
        final remote = di.sl<SupabaseRemoteDatasource>();
        final url = await remote.uploadPostMediaBytes(_currentUserId, bytes, ext);

        if (mounted) {
          context.read<ChatBloc>().add(SendMessageEvent(
            currentUserId: _currentUserId,
            otherUserId: widget.otherUserId,
            content: isVideo ? '[Video]' : '[Hình ảnh]',
            type: isVideo ? MessageType.video : MessageType.image,
            mediaUrl: url,
          ));
        }
      } else {
        // Mobile vẫn dùng path như cũ
        context.read<ChatBloc>().add(SendMessageEvent(
          currentUserId: _currentUserId,
          otherUserId: widget.otherUserId,
          content: isVideo ? '[Video]' : '[Hình ảnh]',
          type: isVideo ? MessageType.video : MessageType.image,
          mediaUrl: file.path,
        ));
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            AvatarWidget(
              name: _otherUser?.name ?? 'User',
              imageUrl: _otherUser?.avatarUrl,
              radius: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _otherUser?.name ?? 'Người dùng',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) return const Center(child: CircularProgressIndicator());
                if (state is ChatLoaded) {
                  final msgs = state.messages;
                  if (msgs.isEmpty) {
                    return const Center(child: Text('Hãy gửi lời chào đầu tiên!', style: TextStyle(color: Colors.grey)));
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients && !_scrollController.position.isScrollingNotifier.value) {
                       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    itemCount: msgs.length,
                    itemBuilder: (context, index) {
                      final msg = msgs[index];
                      final isMe = msg.senderId == _currentUserId;
                      return _buildMessageBubble(msg, isMe);
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
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppTheme.primaryBlue),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: AppTheme.primaryBlue),
                    onPressed: () => _pickMedia(false, fromCamera: true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo, color: AppTheme.primaryBlue),
                    onPressed: () => _pickMedia(false),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Nhắn tin...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
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

  Widget _buildMessageBubble(MessageEntity msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: msg.type == MessageType.text 
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: isMe ? AppTheme.primaryBlue : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomRight: isMe ? const Radius.circular(4) : null,
                bottomLeft: !isMe ? const Radius.circular(4) : null,
              ),
            ),
            child: _buildMessageContent(msg, isMe),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(MessageEntity msg, bool isMe) {
    if (msg.type == MessageType.image) {
      if (msg.mediaUrl == null || msg.mediaUrl!.isEmpty) return const SizedBox();
      
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: msg.mediaUrl!.startsWith('http')
            ? Image.network(
                msg.mediaUrl!, 
                fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) => _errorPlaceholder(),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              )
            : kIsWeb 
                ? _errorPlaceholder() // Trên Web không dùng được path local
                : Image.file(File(msg.mediaUrl!), fit: BoxFit.cover),
      );
    } else if (msg.type == MessageType.video) {
      return Container(
        height: 200,
        width: 150,
        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(14)),
        child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50)),
      );
    }
    return Text(
      msg.content,
      style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15),
    );
  }

  Widget _errorPlaceholder() => Container(
    padding: const EdgeInsets.all(20),
    color: Colors.grey.shade300,
    child: const Icon(Icons.broken_image, color: Colors.grey),
  );
}
