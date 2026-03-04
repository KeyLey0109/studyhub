import 'dart:io';
import 'package:dartz/dartz.dart';
import '../repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  /// Hàm call hỗ trợ đăng bài kèm tên người dùng, nội dung, ảnh hoặc video cho Mobile
  Future<Either<String, void>> call({
    required String content,
    required String userName, // Thêm tham số này để sửa lỗi gạch đỏ
    File? image,
    File? video,
  }) async {
    // 1. Ràng buộc nghiệp vụ: Bài viết của sinh viên PYU không được để trống hoàn toàn
    if (content.trim().isEmpty && image == null && video == null) {
      return const Left("Nội dung bài viết không được để trống!");
    }

    // 2. Gọi xuống Repository để xử lý lưu trữ kèm tên người đăng
    return await repository.createPost(
      content: content,
      userName: userName, // Truyền userName xuống tầng Data
      image: image,
      video: video,
    );
  }
}