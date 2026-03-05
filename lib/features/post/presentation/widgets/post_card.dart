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

class PostCard extends StatefulWidget {
  final PostEntity post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = false; // Xử lý nút "Xem thêm"

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

    final bool isMyLike = widget.post.isLikedBy(currentUserId);
    final int totalComments = _getTotalCommentsCount(widget.post.comments);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 0.5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _PostHeader(post: widget.post),
          ),

          // 2. Nội dung văn bản (Có xử lý "Xem thêm")
          if (widget.post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: _buildExpandableText(widget.post.content),
            ),

          // 3. Media (Ảnh/Video)
          _buildMediaSection(),

          // 4. Thống kê tương tác
          if (widget.post.likeCount > 0 || totalComments > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.post.likeCount > 0)
                    Row(
                      children: [
                        _buildLikeIconStack(), // Hiệu ứng icon Like
                        const SizedBox(width: 6),
                        Text('${widget.post.likeCount}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    )
                  else
                    const SizedBox.shrink(),

                  GestureDetector(
                    onTap: () => _openCommentSheet(context),
                    child: Text(
                      totalComments == 0 ? '' : '$totalComments bình luận',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 1, thickness: 0.3, indent: 12, endIndent: 12),

          // 5. Nút bấm tương tác
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Row(
              children: [
                _PostButton(
                  iconData: isMyLike ? Icons.thumb_up : Icons.thumb_up_off_alt,
                  label: 'Thích',
                  color: isMyLike ? const Color(0xFF1877F2) : Colors.black87,
                  onTap: () => context.read<PostBloc>().add(ToggleLike(postId: widget.post.id)),
                ),
                _PostButton(
                  iconData: Icons.chat_bubble_outline_rounded,
                  label: 'Bình luận',
                  onTap: () => _openCommentSheet(context),
                ),
                _PostButton(
                  iconData: Icons.share_outlined,
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

  // Widget xử lý văn bản quá dài
  Widget _buildExpandableText(String text) {
    const int maxLines = 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: _isExpanded ? null : maxLines,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black),
        ),
        if (text.length > 150 && !_isExpanded)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = true),
            child: const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text("Xem thêm", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  // Widget hiển thị media
  Widget _buildMediaSection() {
    if (widget.post.imagePath != null && widget.post.imagePath!.isNotEmpty) {
      return Image.file(
        File(widget.post.imagePath!),
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    if (widget.post.videoPath != null && widget.post.videoPath!.isNotEmpty) {
      return PostVideoPlayer(videoPath: widget.post.videoPath!);
    }
    return const SizedBox.shrink();
  }

  // Icon Like vòng tròn xanh
  Widget _buildLikeIconStack() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.thumb_up, color: Colors.white, size: 10),
    );
  }

  void _openCommentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentSheet(postId: widget.post.id),
    );
  }
}

// Giữ nguyên các Widget con _PostHeader và _PostButton nhưng tối ưu UI
class _PostHeader extends StatelessWidget {
  final PostEntity post;
  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          child: Text(
            post.userName.isNotEmpty ? post.userName[0].toUpperCase() : '?',
            style: const TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Row(
                children: [
                  Text(
                    '${post.timestamp.day} thg ${post.timestamp.month} lúc ${post.timestamp.hour}:${post.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.public, color: Colors.grey[600], size: 12.0),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.more_horiz, color: Colors.grey),
      ],
    );
  }
}

class _PostButton extends StatelessWidget {
  final IconData iconData;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _PostButton({
    required this.iconData,
    required this.label,
    required this.onTap,
    this.color = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, color: color, size: 20),
              const SizedBox(width: 6.0),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}