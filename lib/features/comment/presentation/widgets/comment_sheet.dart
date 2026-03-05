import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/comment_entity.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';
import 'comment_item.dart';
import '../../../post/presentation/bloc/post_bloc.dart';
import '../../../post/presentation/bloc/post_event.dart';
import '../../../post/presentation/bloc/post_state.dart';

class CommentSheet extends StatefulWidget {
  final String postId;

  const CommentSheet({super.key, required this.postId});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  CommentEntity? _replyingTo;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onReplyRequested(CommentEntity comment) {
    setState(() {
      _replyingTo = comment;
    });
    _focusNode.requestFocus(); // Tự động mở bàn phím khi bấm phản hồi
  }

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<CommentBloc>().add(
      SubmitComment(
        postId: widget.postId,
        content: text,
        parentCommentId: _replyingTo?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentSuccess) {
          _controller.clear();
          _focusNode.unfocus();
          setState(() => _replyingTo = null);
          // Cập nhật lại danh sách bài viết để đồng bộ số lượng comment
          context.read<PostBloc>().add(const LoadPosts());
        } else if (state is CommentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85, // Tăng chiều cao một chút cho thoải mái
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Thanh cầm nắm (Drag handle)
            _buildDragHandle(),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text("Bình luận", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const Divider(height: 1),

            // Danh sách bình luận
            Expanded(
              child: BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  if (state is PostLoaded) {
                    try {
                      final currentPost = state.posts.firstWhere((p) => p.id == widget.postId);
                      final comments = currentPost.comments;

                      if (comments.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        itemCount: comments.length,
                        itemBuilder: (context, index) => CommentItem(
                          comment: comments[index],
                          onReply: _onReplyRequested,
                        ),
                      );
                    } catch (e) {
                      return const Center(child: Text("Không tìm thấy bài viết"));
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),

            // Thanh nhập liệu & Trạng thái phản hồi
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 4, width: 40,
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey[300]),
        const SizedBox(height: 10),
        const Text("Chưa có bình luận nào", style: TextStyle(color: Colors.grey)),
        const Text("Hãy là người đầu tiên chia sẻ ý kiến!", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        left: 12, right: 12, top: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8.0),
              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "Đang trả lời ",
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                        children: [
                          TextSpan(text: _replyingTo!.userName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _replyingTo = null),
                    child: const Icon(Icons.cancel, size: 20, color: Colors.grey),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Viết bình luận...",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _buildSendButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        if (state is CommentLoading) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return IconButton(
          icon: const Icon(Icons.send_rounded, color: Color(0xFF1877F2)),
          onPressed: _submitComment,
        );
      },
    );
  }
}