import 'package:dartz/dartz.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository repository;

  GetPostsUseCase(this.repository);

  /// Hàm thực thi lấy danh sách bài viết
<<<<<<< HEAD
  /// [userId]: Nếu có, chỉ lấy bài viết của user này (dùng cho trang cá nhân)
  Future<Either<String, List<PostEntity>>> call({String? userId}) async {
    return await repository.getPosts(userId: userId);
  }
}
=======
  /// Trả về Either: Left là String thông báo lỗi, Right là danh sách PostEntity thành công
  Future<Either<String, List<PostEntity>>> call() async {
    return await repository.getPosts();
  }
}
>>>>>>> origin/feature
