import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FacebookApi {
  // ✅ ĐÃ SỬA: ID chuẩn của Fanpage DEX CODER
  static const String _pageId = '630344643494436';

  // ✅ Token vĩnh viễn của bạn
  static const String _pageAccessToken =
      'EAAcxgVOuK7ABQZCLJ06WnaP4dtxZCDCU9scJRFNpQ1NNHr6sveaSRRQO1PutEdmOs9dobQnaYuyVtZA6UmpCQPYjr34N2qg61Eko2bOSJw49sBCLlbZALOsfzUiuxOGjNZAq9KHFskwm0QXkZBD6AZAmsfJJFYdCNA5khORRs9kdecRi0yQ5q3ZBwZAzzYZBzwwYMHZAVDB';

  /// Hàm gửi bài viết lên Fanpage (hỗ trợ cả văn bản, hình ảnh và video)
  static Future<bool> postToFanpage(String message,
      {List<String>? mediaPaths, List<String>? mediaTypes}) async {
    try {
      debugPrint('🚀 Đang chuẩn bị đăng bài lên Facebook Fanpage...');

      // Kiểm tra nếu có video trong danh sách
      final videoIndex = mediaTypes?.indexOf('video') ?? -1;

      if (videoIndex != -1 && mediaPaths != null) {
        // TRƯỜNG HỢP 1: CÓ VIDEO -> Phải dùng endpoint /videos riêng
        debugPrint('📹 Phát hiện video, đang đăng trực tiếp lên endpoint /videos...');
        final videoPath = mediaPaths[videoIndex];
        
        final Uri url = Uri.parse('https://graph-video.facebook.com/v19.0/$_pageId/videos');
        final request = http.MultipartRequest('POST', url);
        request.fields['access_token'] = _pageAccessToken;
        request.fields['description'] = message;
        
        request.files.add(await http.MultipartFile.fromPath('source', videoPath));

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          debugPrint('✅ Đăng Video lên Fanpage thành công!');
          return true;
        } else {
          debugPrint('❌ Lỗi đăng Video: ${response.body}');
          return false;
        }
      }

      // TRƯỜNG HỢP 2: CHỈ CÓ ẢNH HOẶC CHỈ CÓ CHỮ
      final List<String> mediaIds = [];
      if (mediaPaths != null &&
          mediaTypes != null &&
          mediaPaths.isNotEmpty &&
          mediaPaths.length == mediaTypes.length) {
        for (int i = 0; i < mediaPaths.length; i++) {
          final id = await _uploadPhoto(mediaPaths[i]);
          if (id != null) {
            mediaIds.add(id);
          }
        }
      }

      // Đăng bài lên feed
      final Uri url = Uri.parse('https://graph.facebook.com/v19.0/$_pageId/feed');
      final Map<String, String> body = {
        'message': message,
        'access_token': _pageAccessToken,
      };

      if (mediaIds.isNotEmpty) {
        final List<Map<String, String>> attachedMedia =
            mediaIds.map((id) => {'media_fbid': id}).toList();
        body['attached_media'] = jsonEncode(attachedMedia);
      }

      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        debugPrint('✅ Đăng bài lên Fanpage thành công!');
        return true;
      } else {
        debugPrint('❌ Lỗi đăng Feed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Lỗi xử lý đăng bài: $e');
      return false;
    }
  }

  /// Hàm tải ảnh lên Facebook dưới dạng unpublished
  static Future<String?> _uploadPhoto(String path) async {
    final Uri url = Uri.parse('https://graph.facebook.com/v19.0/$_pageId/photos');

    try {
      final request = http.MultipartRequest('POST', url);
      request.fields['access_token'] = _pageAccessToken;
      request.fields['published'] = 'false';
      request.files.add(await http.MultipartFile.fromPath('source', path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id']?.toString();
      } else {
        debugPrint('❌ Lỗi tải ảnh: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Lỗi kết nối tải ảnh: $e');
      return null;
    }
  }
}
