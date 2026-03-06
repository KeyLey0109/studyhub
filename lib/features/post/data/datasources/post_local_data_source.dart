import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';

abstract class PostLocalDataSource {
  Future<void> cachePosts(List<PostModel> postsToCache, {String? userId});
  Future<List<PostModel>> getLastPosts({String? userId});
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  final SharedPreferences sharedPreferences;

  // Key cơ sở để lưu bài viết
  static const _baseKey = 'CACHED_POSTS_USER_';
  // Key cũ để đảm bảo không mất dữ liệu nếu userId là null
  static const _legacyKey = 'CACHED_POSTS_STUDYHUB_V2';

  PostLocalDataSourceImpl({required this.sharedPreferences});

  String _getKey(String? userId) =>
      userId != null ? '$_baseKey$userId' : _legacyKey;

  @override
  Future<void> cachePosts(List<PostModel> postsToCache,
      {String? userId}) async {
    final List<String> jsonPostList =
        postsToCache.map((post) => json.encode(post.toJson())).toList();

    await sharedPreferences.setStringList(_getKey(userId), jsonPostList);
  }

  @override
  Future<List<PostModel>> getLastPosts({String? userId}) async {
    final key = _getKey(userId);
    final jsonList = sharedPreferences.getStringList(key);

    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    try {
      final List<PostModel> posts = [];
      for (final jsonString in jsonList) {
        try {
          posts.add(PostModel.fromJson(
              json.decode(jsonString) as Map<String, dynamic>));
        } catch (e) {
          debugPrint("Lỗi parse bài viết: $e");
        }
      }
      return posts;
    } catch (e) {
      debugPrint("Lỗi khi tải bài viết ($key): $e");
      await sharedPreferences.remove(key);
      return [];
    }
  }
}
