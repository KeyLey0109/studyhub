import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.userName,
    required super.content,
    required super.createdAt,
  });

  // Chuyển đổi từ JSON (giả lập API)
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      postId: json['postId'],
      userName: json['userName'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}