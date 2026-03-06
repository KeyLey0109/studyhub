import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/post_entity.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

/// 1. Tải danh sách bài viết
/// Được gọi khi mở App, Refresh trang hoặc sau khi đăng bài thành công.
class LoadPosts extends PostEvent {
  const LoadPosts();
}

/// 2. Sự kiện đăng bài viết mới
/// Chấp nhận File hình ảnh hoặc video từ bộ nhớ máy thông qua ImagePicker.
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

/// 3. Sự kiện Thích/Bỏ thích bài viết (Toggle Like)
/// Chỉ cần postId, việc xác định User ID sẽ do Bloc lấy từ AuthBloc.
class ToggleLike extends PostEvent {
  final String postId;

  const ToggleLike({required this.postId});

  @override
  List<Object?> get props => [postId];
}

/// 4. Sự kiện thêm bình luận
/// Mang nội dung bình luận đến Bloc để tạo đối tượng CommentEntity mới.
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

/// 5. Cập nhật bài viết cục bộ (Local Update)
/// Dùng để cập nhật ngay lập tức một bài viết cụ thể trong danh sách mà không cần reload toàn bộ.
class UpdatePost extends PostEvent {
  final PostEntity post;

  const UpdatePost({required this.post});

  @override
  List<Object?> get props => [post];
}

/// 6. Xóa bài viết
/// Chỉnh sửa named parameter để đồng bộ với cách gọi trong Bloc.
class DeletePost extends PostEvent {
  final String postId;

  const DeletePost({required this.postId});

  @override
  List<Object?> get props => [postId];
}