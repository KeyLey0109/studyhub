import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/comment_entity.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';
import 'comment_item.dart';
// Import thêm PostBloc để đồng bộ dữ liệu
import '../../../post/presentation/bloc/post_bloc.dart';
import '../../../post/presentation/bloc/post_event.dart';
import '../../../post/presentation/bloc/post_state.dart';

class CommentSheet extends StatefulWidget {
  final String postId;

  const CommentSheet({
    super.key,
    required this.postId,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();
  CommentEntity? _replyingTo;

  void _onReplyRequested(CommentEntity comment) {
    setState(() {
      _replyingTo = comment;
    });
  }

  void _submitComment() {
    if (_controller.text.trim().isEmpty) return;

    context.read<CommentBloc>().add(
      SubmitComment(
        postId: widget.postId,
        content: _controller.text.trim(),
        parentCommentId: _replyingTo?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Dùng BlocListener để xóa text và cập nhật danh sách bài viết khi gửi thành công
    return BlocListener<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentSuccess) {
          _controller.clear();
          setState(() => _replyingTo = null);
          // QUAN TRỌNG: Ép PostBloc tải lại dữ liệu mới nhất từ máy để cập nhật Like/Comment
          context.read<PostBloc>().add(const LoadPosts());
        } else if (state is CommentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 4, width: 40,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const Text("Bình luận", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),

            // 2. Dùng BlocBuilder của PostBloc để lấy danh sách bình luận mới nhất từ bộ nhớ máy
            Expanded(
              child: BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  if (state is PostLoaded) {
                    // Tìm đúng bài viết hiện tại trong danh sách đã nạp từ máy
                    final currentPost = state.posts.firstWhere((p) => p.id == widget.postId);
                    final comments = currentPost.comments;

                    if (comments.isEmpty) {
                      return const Center(child: Text("Hãy là người đầu tiên bình luận!"));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return CommentItem(
                          comment: comments[index],
                          onReply: _onReplyRequested,
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),

            if (_replyingTo != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blue.withValues(alpha:0.1),
                child: Row(
                  children: [
                    Expanded(child: Text("Đang trả lời ${_replyingTo!.userName}", style: const TextStyle(fontSize: 12, color: Colors.blue))),
                    GestureDetector(onTap: () => setState(() => _replyingTo = null), child: const Icon(Icons.close, size: 16, color: Colors.blue)),
                  ],
                ),
              ),

            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 10, left: 10, right: 10, top: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Viết bình luận...",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                        filled: true, fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<CommentBloc, CommentState>(
                    builder: (context, state) {
                      if (state is CommentLoading) {
                        return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
                      }
                      return IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: _submitComment);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}