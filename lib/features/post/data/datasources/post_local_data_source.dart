import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';

abstract class PostLocalDataSource {
  /// Lưu danh sách bài viết vào bộ nhớ máy (SharedPreferences)
  Future<void> cachePosts(List<PostModel> postsToCache);

  /// Lấy danh sách bài viết đã lưu từ bộ nhớ máy
  Future<List<PostModel>> getLastPosts();
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  final SharedPreferences sharedPreferences;

  // Key riêng biệt để tránh xung đột dữ liệu trên thiết bị sinh viên PYU
  static const cachedPostsKey = 'CACHED_POSTS_STUDYHUB_V2';

  PostLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cachePosts(List<PostModel> postsToCache) async {
    // 1. Chuyển danh sách Model thành mảng các chuỗi JSON
    final List<String> jsonPostList = postsToCache
        .map((post) => json.encode(post.toJson()))
        .toList();

    // 2. Lưu mảng chuỗi vào SharedPreferences
    await sharedPreferences.setStringList(cachedPostsKey, jsonPostList);
  }

  @override
  Future<List<PostModel>> getLastPosts() async {
    // 1. Đọc danh sách chuỗi JSON từ máy
    final jsonList = sharedPreferences.getStringList(cachedPostsKey);

    if (jsonList != null) {
      try {
        // 2. Giải mã từng chuỗi JSON và chuyển đổi lại thành PostModel
        return jsonList.map((jsonPost) {
          final Map<String, dynamic> decodedData = json.decode(jsonPost) as Map<String, dynamic>;
          return PostModel.fromJson(decodedData);
        }).toList();
      } catch (e) {
        // Nếu dữ liệu cũ (V1) không tương thích với cấu trúc Comment mới (V2), xóa bỏ để tránh crash
        await sharedPreferences.remove(cachedPostsKey);
        return [];
      }
    }
    return [];
  }
}