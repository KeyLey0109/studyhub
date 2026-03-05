import 'package:equatable/equatable.dart';
import '../../domain/entities/post_entity.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

/// 1. Trạng thái khởi tạo
class PostInitial extends PostState {}

/// 2. Trạng thái tải toàn bộ trang (Dùng khi mới vào app)
class PostLoading extends PostState {}

/// 3. Trạng thái đã tải dữ liệu thành công
class PostLoaded extends PostState {
  final List<PostEntity> posts;

  // Thêm flag để biết có đang trong quá trình đăng bài mới hay không
  final bool isCreating;

  const PostLoaded({
    required this.posts,
    this.isCreating = false,
  });

  // Hỗ trợ cập nhật trạng thái mà không làm mất danh sách bài viết hiện tại
  PostLoaded copyWith({
    List<PostEntity>? posts,
    bool? isCreating,
  }) {
    return PostLoaded(
      posts: posts ?? this.posts,
      isCreating: isCreating ?? this.isCreating, // Sửa ở đây nè!
    );
  }

  @override
  List<Object?> get props => [posts, isCreating];
}

/// 4. Trạng thái xảy ra lỗi
class PostError extends PostState {
  final String message;

  const PostError({required this.message});

  @override
  List<Object?> get props => [message];
}