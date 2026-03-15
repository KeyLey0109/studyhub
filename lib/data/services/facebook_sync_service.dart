import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../domain/entities/post_entity.dart';

class FacebookSyncService {
  final String userAccessToken; // Đổi tên cho rõ ràng: Đây là token của User

  FacebookSyncService({required this.userAccessToken});

  /// Kiểm tra xem Token hiện tại có hợp lệ không
  Future<bool> checkTokenValidity() async {
    try {
      final url = Uri.parse(
          'https://graph.facebook.com/debug_token?input_token=$userAccessToken&access_token=$userAccessToken');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Lấy danh sách bài viết từ Facebook Feed của User
  Future<List<PostEntity>> fetchFacebookPosts({
    required String fbUserId,
    required String fbUserName,
    String? fbUserAvatar,
  }) async {
    try {
      final url = Uri.parse(
          'https://graph.facebook.com/v19.0/$fbUserId/posts?fields=message,created_time,full_picture&access_token=$userAccessToken');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List postsData = data['data'] ?? [];
        final List<PostEntity> posts = [];

        for (var post in postsData) {
          final String? message = post['message'];
          // Chỉ lấy các bài viết có nội dung văn bản
          if (message == null || message.isEmpty) continue;

          final List<String> mediaUrls = [];
          final List<String> mediaTypes = [];

          if (post['full_picture'] != null) {
            mediaUrls.add(post['full_picture']);
            mediaTypes.add('image');
          }

          posts.add(PostEntity(
            id: 'fb_${post['id']}',
            authorId: 'fb_$fbUserId',
            authorName: fbUserName,
            authorAvatar: fbUserAvatar,
            content: message,
            mediaUrls: mediaUrls,
            mediaTypes: mediaTypes,
            likedByIds: const [],
            comments: const [],
            createdAt: DateTime.parse(post['created_time']),
          ));
        }
        return posts;
      } else {
        debugPrint('❌ Fetch FB Posts Fail: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Fetch FB Posts Error: $e');
      return [];
    }
  }

  /// HÀM MỚI: Lấy Page Access Token của một Fanpage cụ thể
  Future<String> _getPageAccessToken(String pageId) async {
    final url = Uri.parse(
        'https://graph.facebook.com/v19.0/me/accounts?access_token=$userAccessToken');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List pages = data['data'];

      for (var page in pages) {
        if (page['id'] == pageId) {
          return page['access_token']; // Tìm thấy và trả về Token của Fanpage
        }
      }
      throw Exception(
          'Không tìm thấy Fanpage này hoặc bạn không có quyền Admin.');
    } else {
      throw Exception('Không thể lấy danh sách Fanpage: ${response.body}');
    }
  }

  /// Đăng bài (Chỉ dùng cho Fanpage)
  Future<void> publishPost(
      {String? message, String? link, required String pageId}) async {
    try {
      // BƯỚC 1: Lấy Token riêng của Page
      final pageAccessToken = await _getPageAccessToken(pageId);

      // BƯỚC 2: Dùng Page Token để đăng bài
      final url = Uri.parse('https://graph.facebook.com/v19.0/$pageId/feed');

      final response = await http.post(
        url,
        body: {
          'message': message ?? '',
          if (link != null) 'link': link,
          'access_token':
              pageAccessToken, // ✅ Dùng Token của Page, KHÔNG dùng User Token
        },
      );

      if (response.statusCode != 200) {
        debugPrint('❌ Publish Fail: ${response.body}');
        throw Exception(
            'Lỗi khi đăng bài: ${json.decode(response.body)['error']['message']}');
      }

      debugPrint('✅ Đăng bài lên Fanpage thành công!');
    } catch (e) {
      debugPrint('Publish Error: $e');
      rethrow;
    }
  }
}