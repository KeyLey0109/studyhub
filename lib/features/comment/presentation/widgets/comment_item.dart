import 'package:flutter/material.dart';
import '../../domain/entities/comment_entity.dart';

class CommentItem extends StatelessWidget {
  final CommentEntity comment;
  final Function(CommentEntity) onReply;
  final int depth; // Độ sâu để thụt lề

  const CommentItem({
    super.key,
    required this.comment,
    required this.onReply,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: EdgeInsets.only(
            left: 12.0 + (depth * 20), // Thụt lề theo tầng
            right: 12.0,
            top: 4.0,
            bottom: 4.0,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.userName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(comment.content, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        // Nút phản hồi dưới mỗi bình luận
        Padding(
          padding: EdgeInsets.only(left: 20.0 + (depth * 20), bottom: 8),
          child: InkWell(
            onTap: () => onReply(comment),
            child: const Text(
              "Trả lời",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        // Đệ quy hiển thị các câu trả lời con
        if (comment.replies.isNotEmpty)
          ...comment.replies.map((reply) => CommentItem(
            comment: reply,
            onReply: onReply,
            depth: depth + 1,
          )),
      ],
    );
  }
}