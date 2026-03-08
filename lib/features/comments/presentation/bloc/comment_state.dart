import '../../domain/entities/comment_entity.dart';

abstract class CommentState {}

class CommentInitial extends CommentState {}
class CommentLoading extends CommentState {}
class CommentLoaded extends CommentState {
  final List<CommentEntity> comments;
  CommentLoaded(this.comments);
}
class CommentError extends CommentState {
  final String message;
  CommentError(this.message);
}