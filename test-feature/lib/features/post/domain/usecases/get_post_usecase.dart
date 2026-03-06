import 'package:dartz/dartz.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository repository;

  GetPostsUseCase(this.repository);

  /// Hàm thực thi lấy danh sách bài viết
  /// Trả về Either: Left là String thông báo lỗi, Right là danh sách PostEntity thành công
  Future<Either<String, List<PostEntity>>> call() async {
    return await repository.getPosts();
  }
}