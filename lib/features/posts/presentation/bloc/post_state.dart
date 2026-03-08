import '../../domain/entities/post_entities.dart'; // Đảm bảo đường dẫn đúng

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<dynamic> posts; // Định nghĩa 'posts' để fix lỗi image_016c6f
  PostLoaded({required this.posts});
}

class PostError extends PostState {
  final String message; // Định nghĩa 'message' để fix lỗi image_0170e5
  PostError(this.message);
}