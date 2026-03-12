import 'package:get_it/get_it.dart'; // Thêm GetIt để gọi API WordPress
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/friend_repository.dart';
import '../datasources/local/hive_local_datasource.dart';
import '../datasources/remote/supabase_remote_datasource.dart';
import '../datasources/remote/wordpress_remote_datasource.dart'; // Import WordPress API

class PostRepositoryImpl implements PostRepository {
  final SupabaseRemoteDatasource remote;
  final HiveLocalDatasource local;

  PostRepositoryImpl({required this.remote, required this.local});

  @override
  Future<List<PostEntity>> getPosts({int page = 1, int limit = 10}) async {
    try {
      // 1. Gọi tên lửa kéo bài viết từ trang WordPress của bạn về
      final wpRemote = GetIt.instance<PostRemoteDataSource>();
      final wpPosts = await wpRemote.getPosts();

      // 2. Kéo thêm các bài viết người dùng tự đăng trên App (từ Supabase/Fake)
      List<PostEntity> appPosts = [];
      try {
        appPosts = await remote.getPosts(page: page, limit: limit);
      } catch (e) {
        // Bỏ qua nếu app chưa có bài viết nào
      }

      // 3. Trộn cả 2 nguồn bài viết lại với nhau
      final allPosts = [...wpPosts, ...appPosts];

      // 4. Sắp xếp bài nào mới nhất thì ưu tiên đưa lên đầu (như Facebook)
      allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allPosts;
    } catch (e) {
      // Nếu rớt mạng hoặc web lỗi, tự động lôi bài viết cũ trong App ra hiển thị
      return remote.getPosts(page: page, limit: limit);
    }
  }

  @override
  Future<List<PostEntity>> getUserPosts(String userId) async {
    return remote.getUserPosts(userId);
  }

  @override
  Future<PostEntity> createPost({
    required String authorId,
    required String authorName,
    String? authorAvatar,
    String? content,
    List<String> mediaUrls = const [],
    List<String> mediaTypes = const [],
    PostEntity? sharedPost,
  }) =>
      remote.createPost(
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        content: content,
        mediaUrls: mediaUrls,
        mediaTypes: mediaTypes,
        sharedPost: sharedPost,
      );

  @override
  Future<PostEntity> toggleLikePost(String postId, String userId) =>
      remote.toggleLikePost(postId, userId);

  @override
  Future<PostEntity> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required String content,
    String? parentId,
  }) =>
      remote.addComment(
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        content: content,
        parentId: parentId,
      );

  @override
  Future<PostEntity> likeComment(
      String postId, String commentId, String userId) =>
      remote.likeComment(postId, commentId, userId);

  @override
  Future<PostEntity?> getPostById(String postId) async {
    try {
      return await remote.getPostById(postId);
    } catch (e) {
      return local.getPostById(postId);
    }
  }

  @override
  Future<Map<String, dynamic>> search(String query, String userId) =>
      remote.search(query, userId);

  @override
  Future<void> deletePost(String postId) => remote.deletePost(postId);
}

class FriendRepositoryImpl implements FriendRepository {
  final SupabaseRemoteDatasource remote;
  final HiveLocalDatasource local;
  FriendRepositoryImpl({required this.remote, required this.local});

  @override
  Future<void> sendFriendRequest(
      {required String fromId, required String toId}) =>
      remote.sendFriendRequest(fromId, toId);

  @override
  Future<void> acceptFriendRequest(
      {required String fromId, required String toId}) =>
      remote.acceptFriendRequest(fromId, toId);

  @override
  Future<void> declineFriendRequest(
      {required String fromId, required String toId}) =>
      remote.declineFriendRequest(fromId, toId);

  @override
  Future<List<UserEntity>> getFriendRequests(String userId) async =>
      remote.getFriendRequests(userId);

  @override
  Future<List<UserEntity>> getFriends(String userId) async =>
      remote.getFriends(userId);

  @override
  Future<List<UserEntity>> getSuggestions(String userId) async =>
      remote.getSuggestions(userId);

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) async =>
      remote.getNotifications(userId);

  @override
  Future<void> markNotificationRead(String id) =>
      remote.markNotificationRead(id);
}