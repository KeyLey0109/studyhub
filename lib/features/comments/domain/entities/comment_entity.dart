import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String postId;
  final String userName;
  final String content;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, postId, userName, content, createdAt];
}