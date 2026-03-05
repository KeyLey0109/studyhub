import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/post_entity.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

/// 1. Tải danh sách bài viết
class LoadPosts extends PostEvent {
  const LoadPosts();
}

/// 2. Tạo bài viết (Đảm bảo tên class duy nhất trong dự án)
class CreatePostRequested extends PostEvent {
  final String content;
  final String? userName;
  final File? image;
  final File? video;

  const CreatePostRequested({
    required this.content,
    this.userName,
    this.image,
    this.video,
  });

  @override
  List<Object?> get props => [content, userName, image, video];
}

/// 3. Like/Unlike bài viết
class ToggleLike extends PostEvent {
  final String postId;

  const ToggleLike({required this.postId});

  @override
  List<Object?> get props => [postId];
}

/// 4. Thêm bình luận
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

/// 5. Xóa bài viết
class DeletePost extends PostEvent {
  final String postId;

  const DeletePost(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// 6. Cập nhật bài viết
class UpdatePost extends PostEvent {
  final PostEntity post;

  const UpdatePost({required this.post});

  @override
  List<Object?> get props => [post];
}