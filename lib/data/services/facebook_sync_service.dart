import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../domain/entities/post_entity.dart';

class FacebookSyncService {
  final String accessToken;

  FacebookSyncService({required this.accessToken});

  /// Kiểm tra xem Token hiện tại có hợp lệ không trước khi làm việc
  Future<bool> checkTokenValidity() async {
    try {
      final url = Uri.parse(
          'https://graph.facebook.com/debug_token?input_token=$accessToken&access_token=$accessToken');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<PostEntity>> fetchFacebookPosts({
    required String fbUserId,
    required String fbUserName,
    String? fbUserAvatar,
  }) async {
    try {
      // ✅ Lưu ý: Cần quyền 'user_posts' để gọi được /me/feed
      final url = Uri.parse(
        'https://graph.facebook.com/v19.0/me/feed'
        '?fields=id,message,created_time,full_picture,attachments{media,type}'
        '&limit=25'
        '&access_token=$accessToken',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        // Kiểm tra nếu lỗi do Token hết hạn (Error code 190)
        if (errorData['error']?['code'] == 190) {
          debugPrint('❌ Token đã hết hạn, yêu cầu đăng nhập lại.');
        }
        throw Exception('Lỗi Facebook API: ${errorData['error']?['message']}');
      }

      final data = json.decode(response.body);
      final List<dynamic> fbPosts = data['data'] ?? [];
      final List<PostEntity> posts = [];

      for (final fbPost in fbPosts) {
        final String postId = 'fb_post_${fbPost['id']}';
        final String? message = fbPost['message'];
        final String? picture = fbPost['full_picture'];
        final String createdTime = fbPost['created_time'] ?? '';

        // Parse media from attachments
        final List<String> mediaUrls = [];
        final List<String> mediaTypes = [];

        if (picture != null && picture.isNotEmpty) {
          mediaUrls.add(picture);
          mediaTypes.add('image');
        }

        // Also check attachments for videos
        final attachments = fbPost['attachments']?['data'];
        if (attachments != null) {
          for (final att in attachments) {
            final type = att['type'] ?? '';
            if (type == 'video_inline' || type == 'video') {
              final videoUrl = att['media']?['source'];
              if (videoUrl != null) {
                mediaUrls.add(videoUrl);
                mediaTypes.add('video');
              }
            }
          }
        }

        // Skip posts with no content and no media
        if ((message == null || message.isEmpty) && mediaUrls.isEmpty) {
          continue;
        }

        final post = PostEntity(
          id: postId,
          authorId: 'fb_$fbUserId',
          authorName: fbUserName,
          authorAvatar: fbUserAvatar,
          content: message,
          mediaUrls: mediaUrls,
          mediaTypes: mediaTypes,
          createdAt: DateTime.tryParse(createdTime) ?? DateTime.now(),
        );

        posts.add(post);
      }

      return posts;
    } catch (e) {
      debugPrint('FacebookSyncService Error: $e');
      rethrow;
    }
  }

  /// Đăng bài (Cá nhân dùng 'me', Page dùng 'page_id')
  Future<void> publishPost(
      {String? message, String? link, String? pageId}) async {
    try {
      final id = pageId ?? 'me';
      final url = Uri.parse('https://graph.facebook.com/v19.0/$id/feed');

      final response = await http.post(
        url,
        body: {
          'message': message ?? '',
          if (link != null) 'link': link,
          'access_token': accessToken,
        },
      );

      if (response.statusCode != 200) {
        // ✅ Kiểm tra lỗi phân quyền thường gặp
        debugPrint('❌ Publish Fail: ${response.body}');
        throw Exception(
            'Không thể đăng bài. Vui lòng kiểm tra quyền pages_manage_posts.');
      }
    } catch (e) {
      rethrow;
    }
  }
}
