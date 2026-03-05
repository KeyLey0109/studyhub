import 'dart:io';
import 'package:dartz/dartz.dart';
import '../repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  /// Hàm call thực hiện nghiệp vụ đăng bài viết
  Future<Either<String, void>> call({
    required String content,
    required String userName,
    File? image,
    File? video,
  }) async {
    // 1. Kiểm tra nội dung trống
    if (content.trim().isEmpty && image == null && video == null) {
      return const Left("Vui lòng nhập nội dung hoặc chọn ảnh/video!");
    }

    // 2. Kiểm tra dung lượng video (Ví dụ: giới hạn 50MB để tránh lỗi upload)
    if (video != null) {
      final int sizeInBytes = await video.length();
      final double sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb > 50) {
        return const Left("Dung lượng video quá lớn (tối đa 50MB)!");
      }
    }

    // 3. Gọi xuống Repository để xử lý lưu trữ
    return await repository.createPost(
      content: content.trim(),
      userName: userName,
      image: image,
      video: video,
    );
  }
}