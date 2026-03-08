abstract class CommentEvent {}

class LoadComments extends CommentEvent {
  final String postId;
  LoadComments(this.postId);
}

class AddComment extends CommentEvent {
  final String postId;
  final String content;
  AddComment({required this.postId, required this.content});
}