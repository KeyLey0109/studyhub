import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post_entity.dart';
import '../../../comment/domain/entities/comment_entity.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

import 'post_video_player.dart';
import '../../../comment/presentation/widgets/comment_sheet.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;

  const PostCard({super.key, required this.post});

  // --- THUẬT TOÁN ĐẾM TỔNG BÌNH LUẬN (ĐỆ QUY) ---
  int _getTotalCommentsCount(List<CommentEntity> comments) {
    int total = comments.length;
    for (var comment in comments) {
      if (comment.replies.isNotEmpty) {
        total += _getTotalCommentsCount(comment.replies);
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String currentUserId = '';
    if (authState is AuthSuccess) {
      currentUserId = authState.user.id;
    }

    final bool isMyLike = post.isLikedBy(currentUserId);
    final int totalComments = _getTotalCommentsCount(post.comments);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bài viết
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PostHeader(post: post),
                const SizedBox(height: 10.0),
                if (post.content.isNotEmpty)
                  Text(
                    post.content,
                    style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
                  ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),

          // Hiển thị nội dung đa phương tiện
          if (post.imagePath != null && post.imagePath!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Image.file(
                File(post.imagePath!),
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),

          if (post.videoPath != null && post.videoPath!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: PostVideoPlayer(videoPath: post.videoPath!),
            ),

          // --- THỐNG KÊ TƯƠNG TÁC ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (post.likeCount > 0)
                  Row(
                    children: [
                      const Icon(Icons.thumb_up, color: Colors.blue, size: 14),
                      const SizedBox(width: 4),
                      Text('${post.likeCount}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  )
                else
                  const SizedBox.shrink(),

                // HIỂN THỊ TỔNG SỐ BÌNH LUẬN (BAO GỒM CẢ REPLIES)
                GestureDetector(
                  onTap: () => _openCommentSheet(context),
                  child: Text(
                    totalComments == 0
                        ? 'Chưa có bình luận'
                        : '$totalComments bình luận',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5),

          // Nút bấm tương tác
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Row(
              children: [
                _PostButton(
                  icon: Icon(
                    isMyLike ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: isMyLike ? Colors.blue : Colors.grey[700],
                    size: 20,
                  ),
                  label: 'Thích',
                  labelColor: isMyLike ? Colors.blue : Colors.grey[700],
                  onTap: () => context.read<PostBloc>().add(ToggleLike(postId: post.id)),
                ),
                _PostButton(
                  icon: Icon(Icons.chat_bubble_outline, color: Colors.grey[700], size: 20),
                  label: 'Bình luận',
                  onTap: () => _openCommentSheet(context),
                ),
                _PostButton(
                  icon: Icon(Icons.share_outlined, color: Colors.grey[700], size: 20),
                  label: 'Chia sẻ',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openCommentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentSheet(postId: post.id),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final PostEntity post;
  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue.shade50,
          child: Text(
            post.userName.isNotEmpty ? post.userName[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    '${post.timestamp.day}/${post.timestamp.month} lúc ${post.timestamp.hour}:${post.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.public, color: Colors.grey, size: 12.0),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.grey),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _PostButton extends StatelessWidget {
  final Icon icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;

  const _PostButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8.0),
              Text(
                label,
                style: TextStyle(
                  color: labelColor ?? Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}