<<<<<<< HEAD
=======
import 'dart:io';
>>>>>>> origin/feature
import 'package:dartz/dartz.dart';
import '../entities/post_entity.dart';

/// [PostRepository] là Interface định nghĩa các hành động nghiệp vụ liên quan đến bài viết.
/// Tầng Domain sẽ giao tiếp với dữ liệu thông qua Interface này thay vì gọi trực tiếp Data Sources.
abstract class PostRepository {
<<<<<<< HEAD
  /// Lấy danh sách bài viết từ nguồn dữ liệu (Local Cache hoặc Remote API).
  /// Nếu cung cấp [userId], chỉ lấy bài viết của người dùng đó.
  Future<Either<String, List<PostEntity>>> getPosts({String? userId});
=======

  /// Lấy danh sách toàn bộ bài viết từ nguồn dữ liệu (Local Cache hoặc Remote API).
  /// Trả về [Left] chứa thông báo lỗi hoặc [Right] chứa danh sách [PostEntity].
  Future<Either<String, List<PostEntity>>> getPosts();
>>>>>>> origin/feature

  /// Tạo một bài viết mới với nội dung và phương tiện đính kèm (hình ảnh/video).
  /// [content]: Nội dung văn bản của bài viết.
  /// [userName]: Tên hiển thị của sinh viên/người dùng đăng bài.
<<<<<<< HEAD
  Future<Either<String, void>> createPost({
    required String content,
    required String userId,
    required String userName,
    String? imagePath,
    String? videoPath,
    String? userAvatarUrl,
=======
  /// [image]: Tệp hình ảnh đính kèm (không bắt buộc).
  /// [video]: Tệp video đính kèm (không bắt buộc).
  Future<Either<String, void>> createPost({
    required String content,
    required String userName,
    File? image,
    File? video,
>>>>>>> origin/feature
  });

  /// Xử lý hành động Thích (Like) hoặc Bỏ thích (Unlike) bài viết dựa trên ID.
  /// [postId]: Mã định danh duy nhất của bài viết cần tương tác.
  /// [userId]: Mã định danh của người dùng thực hiện hành động.
  Future<Either<String, void>> toggleLike(String postId, String userId);

  /// Thêm một bình luận mới hoặc phản hồi cho bài viết.
  /// [postId]: ID của bài viết được bình luận.
  /// [content]: Nội dung văn bản của bình luận.
  /// [userId]: ID của sinh viên PYU thực hiện bình luận.
  /// [userName]: Tên hiển thị của người bình luận để tối ưu hóa UI.
  /// [parentCommentId]: ID của bình luận gốc nếu đây là một phản hồi (Reply),
  /// để trống (null) nếu là bình luận chính của bài viết.
  Future<Either<String, void>> addComment({
    required String postId,
    required String content,
    required String userId,
    required String userName,
    String? parentCommentId,
  });
<<<<<<< HEAD
}
=======
}
>>>>>>> origin/feature
