import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';
import '../datasources/post_local_data_source.dart';

import '../../../comment/domain/entities/comment_entity.dart';
import '../../../comment/data/models/comment_model.dart';

class PostRepositoryImpl implements PostRepository {
  final PostLocalDataSource localDataSource;

  // Cache trên RAM để xử lý UI mượt mà
  List<PostModel> _postsCache = [];

  PostRepositoryImpl({required this.localDataSource});

  // Tối ưu: Đảm bảo dữ liệu luôn được tải từ máy trước khi xử lý
  Future<void> _ensurePostsLoaded() async {
    if (_postsCache.isEmpty) {
      final cached = await localDataSource.getLastPosts();
      _postsCache = List.from(cached);
    }
  }

  @override
  Future<Either<String, List<PostEntity>>> getPosts() async {
    try {
      final cachedPosts = await localDataSource.getLastPosts();
      if (cachedPosts.isNotEmpty) {
        _postsCache = List.from(cachedPosts);
      } else if (_postsCache.isEmpty) {
        // Khởi tạo bài đăng mặc định cho sinh viên PYU
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
      return Right(_postsCache);
    } catch (e) {
      debugPrint("Lỗi getPosts: $e");
      return const Left("Không thể tải bài viết.");
    }
  }

  @override
  Future<Either<String, void>> createPost({
    required String content,
    required String userName,
    File? image,
    File? video,
  }) async {
    try {
      await _ensurePostsLoaded();
      final newPost = PostModel(
        id: "post_${DateTime.now().millisecondsSinceEpoch}",
        userName: userName,
        content: content,
        imagePath: image?.path,
        videoPath: video?.path,
        timestamp: DateTime.now(),
        likedByUsers: const [],
        comments: const [],
      );

      _postsCache.insert(0, newPost);
      await localDataSource.cachePosts(_postsCache);
      return const Right(null);
    } catch (e) {
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

        // Chuyển đổi qua Model để lưu local an toàn
        _postsCache[index] = PostModel.fromEntity(post.copyWith(likedByUsers: newList));
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

      // Dứt điểm lỗi TypeError bằng cách dùng Model ngay từ đầu
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

      // Cập nhật RAM và lưu xuống máy
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

  // Thuật toán đệ quy chuẩn để cập nhật reply lồng nhau
  List<CommentEntity> _getUpdatedComments(
      List<CommentEntity> currentList,
      String? parentId,
      CommentEntity newComment,
      ) {
    if (parentId == null) {
      return [...currentList, newComment];
    }

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
}