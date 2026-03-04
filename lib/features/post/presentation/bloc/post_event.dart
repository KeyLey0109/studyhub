import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/post_entity.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

/// Sự kiện để tải danh sách bài viết từ Repository
class LoadPosts extends PostEvent {
  const LoadPosts();
}

/// Sự kiện thêm bài viết mới (Đã thêm userName để sửa lỗi gạch đỏ)
class AddPost extends PostEvent {
  final String content;
  final String userName; // Thêm trường này để biết ai là người đăng
  final File? image;
  final File? video;

  const AddPost({
    required this.content,
    required this.userName, // Phải có tên người đăng
    this.image,
    this.video,
  });

  @override
  List<Object?> get props => [content, userName, image, video];
}

/// Sự kiện Like/Unlike bài viết
class ToggleLike extends PostEvent {
  final String postId;

  const ToggleLike({required this.postId});

  @override
  List<Object?> get props => [postId];
}

/// Sự kiện thêm bình luận mới vào bài viết
class AddComment extends PostEvent {
  final String postId;
  final String commentContent;

  const AddComment({
    required this.postId,
    required this.commentContent,
  });

  @override
  List<Object?> get props => [postId, commentContent];
}

/// Sự kiện xóa bài viết
class DeletePost extends PostEvent {
  final String postId;

  const DeletePost(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Sự kiện cập nhật thủ công trạng thái bài viết
class UpdatePost extends PostEvent {
  final PostEntity post;

  const UpdatePost({required this.post});

  @override
  List<Object?> get props => [post];
}