<<<<<<< HEAD
=======
import 'dart:io';
>>>>>>> origin/feature
import 'package:dartz/dartz.dart';
import '../repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  /// Hàm call thực hiện nghiệp vụ đăng bài viết
  Future<Either<String, void>> call({
    required String content,
<<<<<<< HEAD
    required String userId,
    required String userName,
    String? imagePath,
    String? videoPath,
    String? userAvatarUrl,
  }) async {
    // 1. Kiểm tra nội dung trống
    if (content.trim().isEmpty && imagePath == null && videoPath == null) {
      return const Left("Vui lòng nhập nội dung hoặc chọn ảnh/video!");
    }

    // 2. Gọi xuống Repository để xử lý lưu trữ
    return await repository.createPost(
      content: content.trim(),
      userId: userId,
      userName: userName,
      imagePath: imagePath,
      videoPath: videoPath,
      userAvatarUrl: userAvatarUrl,
    );
  }
}
=======
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
>>>>>>> origin/feature
