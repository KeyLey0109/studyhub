import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FacebookApi {
  // ✅ ĐÃ SỬA: ID chuẩn của Fanpage TAROT TO KEY
  static const String _pageId = '630344643494436';

  // ✅ Token vĩnh viễn của bạn
  static const String _pageAccessToken =
      'EAAcxgVOuK7ABQZCLJ06WnaP4dtxZCDCU9scJRFNpQ1NNHr6sveaSRRQO1PutEdmOs9dobQnaYuyVtZA6UmpCQPYjr34N2qg61Eko2bOSJw49sBCLlbZALOsfzUiuxOGjNZAq9KHFskwm0QXkZBD6AZAmsfJJFYdCNA5khORRs9kdecRi0yQ5q3ZBwZAzzYZBzwwYMHZAVDB';

  /// Hàm gửi bài viết lên Fanpage
  static Future<bool> postToFanpage(String message) async {
    // Sử dụng phiên bản API mới nhất v19.0 hoặc v20.0 đều được
    final Uri url = Uri.parse('https://graph.facebook.com/v19.0/$_pageId/feed');

    try {
      debugPrint('🚀 Đang kết nối tới Facebook API...');

      final response = await http.post(
        url,
        body: {
          'message': message,
          'access_token': _pageAccessToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Đăng bài lên TAROT TO KEY thành công!');
        debugPrint('🆔 ID bài viết: ${data['id']}');
        return true;
      } else {
        // In chi tiết lỗi để xử lý nếu có vấn đề về quyền
        debugPrint('❌ Lỗi từ Facebook Server: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Lỗi kết nối mạng: $e');
      return false;
    }
  }
}
