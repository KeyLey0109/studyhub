<<<<<<< HEAD
=======
import 'dart:io';
>>>>>>> origin/feature
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
<<<<<<< HEAD
import '../../../comment/domain/repositories/comment_repository.dart';
=======
>>>>>>> origin/feature
import '../models/post_model.dart';
import '../datasources/post_local_data_source.dart';

import '../../../comment/domain/entities/comment_entity.dart';
import '../../../comment/data/models/comment_model.dart';

<<<<<<< HEAD
class PostRepositoryImpl implements PostRepository, CommentRepository {
=======
class PostRepositoryImpl implements PostRepository {
>>>>>>> origin/feature
  final PostLocalDataSource localDataSource;

  // Cache trên RAM để xử lý UI mượt mà
  List<PostModel> _postsCache = [];

  PostRepositoryImpl({required this.localDataSource});

  // Tối ưu: Đảm bảo dữ liệu luôn được tải từ máy trước khi xử lý
  Future<void> _ensurePostsLoaded() async {
    if (_postsCache.isEmpty) {
<<<<<<< HEAD
      debugPrint("🔄 Cache trống, đang tải từ local storage...");
      final cached = await localDataSource.getLastPosts();
      _postsCache = List<PostModel>.from(cached);
      debugPrint("✅ Đã tải ${_postsCache.length} bài viết vào cache.");
    }
    _ensureAdminPostExists();
  }

  void _ensureAdminPostExists() {
    final hasAdminPost = _postsCache.any((p) => p.id == 'admin_welcome_1');
    if (!hasAdminPost) {
      _postsCache.add(
        PostModel(
          id: 'admin_welcome_1',
          userId: 'admin',
          userName: 'Admin StudyHub',
          content:
              'Chào mừng bạn đến với StudyHub! 🎉\n\nĐây là không gian kết nối, chia sẻ kiến thức và hỗ trợ học tập dành riêng cho sinh viên PYU. Hãy thử đăng bài viết đầu tiên của bạn nhé!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          userAvatarUrl:
              'https://ui-avatars.com/api/?name=Admin+StudyHub&background=1877F2&color=fff&size=128',
          likedByUsers: const [],
          comments: const [],
        ),
      );
      // Sắp xếp lại theo thời gian để admin post có thể ở vị trí hợp lý hoặc cứ để cuối/đầu tùy ý
      // Ở đây ta có thể không cần sắp xếp nếu muốn nó luôn ở một vị trí cố định
=======
      final cached = await localDataSource.getLastPosts();
      // Chuyển đổi dữ liệu sang PostModel tường minh
      _postsCache = List<PostModel>.from(cached);
>>>>>>> origin/feature
    }
  }

  @override
<<<<<<< HEAD
  Future<Either<String, List<PostEntity>>> getPosts({String? userId}) async {
    try {
      await _ensurePostsLoaded();

      // Nếu có userId, lọc bài viết theo user đó (Nhưng luôn giữ lại bài viết của Admin)
      List<PostModel> filteredPosts = _postsCache;
      if (userId != null) {
        filteredPosts = _postsCache
            .where((p) => p.userId == userId || p.userId == 'admin')
            .toList();
        debugPrint(
            "Đang lọc ${filteredPosts.length} bài viết (bao gồm Admin) cho User: $userId");
      } else {
        // Nếu lấy feed chung, đảm bảo cache được lưu nếu có thay đổi (thêm admin post)
        await localDataSource.cachePosts(_postsCache);
      }

      return Right(filteredPosts.cast<PostEntity>());
    } catch (e) {
      debugPrint("Lỗi nghiêm trọng tại getPosts: $e");
=======
  Future<Either<String, List<PostEntity>>> getPosts() async {
    try {
      final cachedPosts = await localDataSource.getLastPosts();

      if (cachedPosts.isNotEmpty) {
        _postsCache = List<PostModel>.from(cachedPosts);
      } else if (_postsCache.isEmpty) {
        _postsCache = [
          PostModel(
            id: '1',
            userName: 'Admin StudyHub',
            content: 'Chào mừng sinh viên PYU đến với StudyHub!',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            likedByUsers: const [],
            comments: const [],
          )
        ];
        await localDataSource.cachePosts(_postsCache);
      }

      // SỬA LỖI TẠI ĐÂY: Sử dụng .cast<PostEntity>() để khớp với kiểu trả về của Interface
      return Right(_postsCache.cast<PostEntity>());
    } catch (e) {
      debugPrint("Lỗi getPosts: $e");
>>>>>>> origin/feature
      return const Left("Không thể tải bài viết.");
    }
  }

  @override
  Future<Either<String, void>> createPost({
    required String content,
<<<<<<< HEAD
    required String userId,
    required String userName,
    String? imagePath,
    String? videoPath,
    String? userAvatarUrl,
=======
    required String userName,
    File? image,
    File? video,
>>>>>>> origin/feature
  }) async {
    try {
      await _ensurePostsLoaded();
      final newPost = PostModel(
        id: "post_${DateTime.now().millisecondsSinceEpoch}",
<<<<<<< HEAD
        userId: userId,
        userName: userName,
        content: content,
        imagePath: imagePath,
        videoPath: videoPath,
        userAvatarUrl: userAvatarUrl,
=======
        userName: userName,
        content: content,
        imagePath: image?.path,
        videoPath: video?.path,
>>>>>>> origin/feature
        timestamp: DateTime.now(),
        likedByUsers: const [],
        comments: const [],
      );

<<<<<<< HEAD
      debugPrint("Đang lưu bài viết mới vào bộ nhớ...");
      _postsCache.insert(0, newPost);
      await localDataSource.cachePosts(_postsCache);
      debugPrint("Lưu bài viết thành công. Tổng cộng: ${_postsCache.length}");
      return const Right(null);
    } catch (e) {
      debugPrint("Lỗi khi lưu bài viết: $e");
=======
      _postsCache.insert(0, newPost);
      await localDataSource.cachePosts(_postsCache);
      return const Right(null);
    } catch (e) {
>>>>>>> origin/feature
      return const Left("Lỗi khi đăng bài viết.");
    }
  }

  @override
  Future<Either<String, void>> toggleLike(String postId, String userId) async {
    try {
      await _ensurePostsLoaded();
      final index = _postsCache.indexWhere((p) => p.id == postId);

      if (index != -1) {
        final post = _postsCache[index];
        List<String> newList = List.from(post.likedByUsers);

        newList.contains(userId) ? newList.remove(userId) : newList.add(userId);

        // Chuyển đổi Entity quay ngược lại Model
<<<<<<< HEAD
        _postsCache[index] =
            PostModel.fromEntity(post.copyWith(likedByUsers: newList));
=======
        _postsCache[index] = PostModel.fromEntity(post.copyWith(likedByUsers: newList));
>>>>>>> origin/feature
        await localDataSource.cachePosts(_postsCache);
      }
      return const Right(null);
    } catch (e) {
      return const Left("Lỗi cập nhật lượt thích.");
    }
  }

  @override
  Future<Either<String, void>> addComment({
    required String postId,
    required String content,
    required String userId,
    required String userName,
    String? parentCommentId,
  }) async {
    try {
      await _ensurePostsLoaded();
      final index = _postsCache.indexWhere((p) => p.id == postId);
      if (index == -1) return const Left("Không tìm thấy bài viết");

      final post = _postsCache[index];

      final newComment = CommentModel(
        id: "cmt_${DateTime.now().millisecondsSinceEpoch}",
        userId: userId,
        userName: userName,
        content: content,
        timestamp: DateTime.now(),
        replies: const [],
      );

      final updatedComments = _getUpdatedComments(
        post.comments,
        parentCommentId,
        newComment,
      );

      // SỬA LỖI TẠI ĐÂY: Dùng PostModel.fromEntity để đảm bảo danh sách comments
      // bên trong cũng được chuyển thành Model trước khi cache
      _postsCache[index] = PostModel.fromEntity(
        post.copyWith(comments: updatedComments),
      );

      await localDataSource.cachePosts(_postsCache);
      return const Right(null);
    } catch (e) {
      debugPrint("Lỗi addComment: $e");
      return const Left("Lỗi khi gửi bình luận.");
    }
  }

  List<CommentEntity> _getUpdatedComments(
<<<<<<< HEAD
    List<CommentEntity> currentList,
    String? parentId,
    CommentEntity newComment,
  ) {
    if (parentId == null) {
      return [...currentList, newComment];
    }
=======
      List<CommentEntity> currentList,
      String? parentId,
      CommentEntity newComment,
      ) {
    if (parentId == null) {
      return [...currentList, newComment];
    }

>>>>>>> origin/feature
    return currentList.map((comment) {
      if (comment.id == parentId) {
        return comment.copyWith(replies: [...comment.replies, newComment]);
      } else if (comment.replies.isNotEmpty) {
        return comment.copyWith(
          replies: _getUpdatedComments(comment.replies, parentId, newComment),
        );
      }
      return comment;
    }).toList();
  }
<<<<<<< HEAD

  @override
  Future<Either<String, List<CommentEntity>>> getComments(String postId) async {
    // Hiện tại bình luận đã nằm trong PostEntity, nếu cần tách riêng có thể xử lý ở đây
    return const Right([]);
  }
}
=======
}
>>>>>>> origin/feature
