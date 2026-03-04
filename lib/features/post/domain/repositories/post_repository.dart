import 'dart:io';
import 'package:dartz/dartz.dart';
import '../entities/post_entity.dart';

abstract class PostRepository {
  /// Lấy danh sách bài viết từ nguồn dữ liệu (Local hoặc API)
  Future<Either<String, List<PostEntity>>> getPosts();

  /// Tạo một bài viết mới với tên người dùng thật
  Future<Either<String, void>> createPost({
    required String content,
    required String userName,
    File? image,
    File? video,
  });

  /// Xử lý Like/Unlike dựa trên UserId
  Future<Either<String, void>> toggleLike(String postId, String userId);

  /// CẬP NHẬT: Thêm bình luận mới với đầy đủ thông tin định danh
  /// [userId]: ID người bình luận
  /// [userName]: Tên hiển thị của sinh viên PYU
  /// [parentCommentId]: ID của bình luận cha (nếu là trả lời/reply)
  Future<Either<String, void>> addComment({
    required String postId,
    required String content,
    required String userId,
    required String userName,
    String? parentCommentId, // null nếu là bình luận chính
  });
}