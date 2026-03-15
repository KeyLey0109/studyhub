import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/story_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/story/story_bloc.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../widgets/common/avatar_widget.dart';

class StoryViewPage extends StatefulWidget {
  final StoryEntity story;
  const StoryViewPage({super.key, required this.story});

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _controller.addListener(() {
      setState(() {});
    });
    _controller.forward().then((_) {
      if (mounted && !_focusNode.hasFocus) context.pop();
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.stop();
      } else {
        if (_controller.status != AnimationStatus.completed) {
          _controller.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _deleteStory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tin'),
        content: const Text('Bạn có chắc chắn muốn xóa tin này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<StoryBloc>().add(DeleteStoryEvent(widget.story.id));
              context.pop();
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<ChatBloc>().add(SendMessageEvent(
            currentUserId: auth.user.id,
            otherUserId: widget.story.userId,
            content: text,
          ));
      
      _messageController.clear();
      _focusNode.unfocus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi tin nhắn phản hồi'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final isOwner = auth is AuthAuthenticated && auth.user.id == widget.story.userId;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Story Content - Full Screen
          Positioned.fill(
            child: widget.story.type == StoryType.image
                ? Image.network(widget.story.url!, fit: BoxFit.cover)
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: widget.story.backgroundColor != null
                            ? [
                                Color(int.parse(widget.story.backgroundColor!.replaceFirst('#', '0xFF'))),
                                Color(int.parse(widget.story.backgroundColor!.replaceFirst('#', '0xFF'))).withValues(alpha: 0.8),
                              ]
                            : [Colors.blueAccent, Colors.blue.shade900],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Center(
                      child: Text(
                        widget.story.content ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 28, 
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)
                          ]
                        ),
                      ),
                    ),
                  ),
          ),

          // Header (Overlay)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _controller.value,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 3,
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      leading: AvatarWidget(
                        name: widget.story.userName,
                        imageUrl: widget.story.userAvatar,
                        radius: 20,
                      ),
                      title: Text(
                        widget.story.userName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text('17 giờ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isOwner)
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_horiz, color: Colors.white),
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _controller.stop();
                                  _deleteStory();
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Xóa tin', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 28),
                            onPressed: () => context.pop(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Footer & Message (Overlay)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  // Nút cộng đã được xóa tại đây
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              focusNode: _focusNode,
                              onChanged: (val) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: 'Gửi tin nhắn...',
                                hintStyle: TextStyle(color: Colors.white70, fontSize: 15),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          if (_messageController.text.trim().isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.white, size: 22),
                              onPressed: _sendMessage,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildReactionIcon('❤️'),
                  _buildReactionIcon('👍'),
                  _buildReactionIcon('😮'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionIcon(String emoji) {
    return GestureDetector(
      onTap: () {
        final auth = context.read<AuthBloc>().state;
        if (auth is AuthAuthenticated) {
          context.read<StoryBloc>().add(ReactToStoryEvent(
            widget.story.id, 
            StoryReaction(userId: auth.user.id, emoji: emoji)
          ));
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bạn đã bày tỏ cảm xúc $emoji'),
            duration: const Duration(seconds: 1), 
            backgroundColor: Colors.black87, 
            behavior: SnackBarBehavior.floating
          ),
        );
      },
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(emoji, style: const TextStyle(fontSize: 28))),
    );
  }
}
