import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';

abstract class PostLocalDataSource {
  Future<void> cachePosts(List<PostModel> postsToCache);
  Future<List<PostModel>> getLastPosts();
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  final SharedPreferences sharedPreferences;

  // Sử dụng key V2 để tách biệt hoàn toàn với dữ liệu cũ chưa có bình luận
  static const cachedPostsKey = 'CACHED_POSTS_STUDYHUB_V2';

  PostLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cachePosts(List<PostModel> postsToCache) async {
    // Chuyển đổi sang JSON String List
    final List<String> jsonPostList = postsToCache
        .map((post) => json.encode(post.toJson()))
        .toList();

    await sharedPreferences.setStringList(cachedPostsKey, jsonPostList);
  }

  @override
  Future<List<PostModel>> getLastPosts() async {
    final jsonList = sharedPreferences.getStringList(cachedPostsKey);

    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    try {
      // Dùng map và toList để chuyển đổi dữ liệu
      return jsonList.map((jsonString) {
        return PostModel.fromJson(json.decode(jsonString) as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      // Nếu dữ liệu không tương thích (ví dụ: thiếu trường comments mới)
      // Xóa cache cũ để đảm bảo ứng dụng không bị lỗi subtype
      await sharedPreferences.remove(cachedPostsKey);
      return [];
    }
  }
}