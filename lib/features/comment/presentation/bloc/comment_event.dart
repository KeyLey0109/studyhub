import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

/// Sự kiện gửi bình luận hoặc câu trả lời
class SubmitComment extends CommentEvent {
  final String postId;
  final String content;
  final String? parentCommentId; // Nếu null là comment chính, nếu có ID là Reply

  const SubmitComment({
    required this.postId,
    required this.content,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [postId, content, parentCommentId];
}