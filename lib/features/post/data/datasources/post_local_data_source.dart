import 'dart:convert';
<<<<<<< HEAD
import 'package:flutter/foundation.dart';
=======
>>>>>>> origin/feature
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
<<<<<<< HEAD
    final List<String> jsonPostList =
        postsToCache.map((post) => json.encode(post.toJson())).toList();
=======
    final List<String> jsonPostList = postsToCache
        .map((post) => json.encode(post.toJson()))
        .toList();
>>>>>>> origin/feature

    await sharedPreferences.setStringList(cachedPostsKey, jsonPostList);
  }

  @override
  Future<List<PostModel>> getLastPosts() async {
    final jsonList = sharedPreferences.getStringList(cachedPostsKey);

    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    try {
<<<<<<< HEAD
      final List<PostModel> posts = [];
      for (final jsonString in jsonList) {
        try {
          posts.add(PostModel.fromJson(
              json.decode(jsonString) as Map<String, dynamic>));
        } catch (e) {
          debugPrint("Lỗi parse bài viết: $e");
          // Bỏ qua bài viết lỗi thay vì xóa hết
        }
      }
      return posts;
    } catch (e) {
      debugPrint("Lỗi nghiêm trọng khi tải bài viết: $e");
      return [];
    }
  }
}
=======
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
>>>>>>> origin/feature
