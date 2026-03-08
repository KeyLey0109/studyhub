import 'package:flutter/material.dart';
import '../../domain/entities/comment_entity.dart';

class CommentItemWidget extends StatelessWidget {
  final CommentEntity comment;
  const CommentItemWidget({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(comment.content),
      trailing: Text("${comment.createdAt.hour}:${comment.createdAt.minute}"),
    );
  }
}