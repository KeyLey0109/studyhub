import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

abstract class FacebookAuthDataSource {
  /// Thực hiện luồng đăng nhập Facebook và trả về AccessToken
  Future<AccessToken> loginWithFacebook();

  /// Đăng xuất khỏi Facebook
  Future<void> logout();
}

class FacebookAuthDataSourceImpl implements FacebookAuthDataSource {
  @override
  Future<AccessToken> loginWithFacebook() async {
    try {
      // 1. BẮT BUỘC CHO iOS: Xin quyền Tracking để tránh lỗi "Limited Login" cản trở Graph API
      if (Platform.isIOS) {
        final TrackingStatus status =
            await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('Trạng thái cấp quyền iOS (ATT): $status');
        // Dù người dùng cho phép hay từ chối, luồng vẫn đi tiếp mượt mà.
      }

      // 2. GỌI SDK ĐĂNG NHẬP: Khai báo trọn bộ quyền mà StudyHub cần sử dụng
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: [
          'email', // Lấy email người dùng
          'public_profile', // Lấy tên, avatar
          'user_posts', // Cấp quyền lấy danh sách bài viết cá nhân
          'pages_show_list', // Cấp quyền lấy danh sách Fanpage đang quản trị
          'pages_manage_posts' // Cấp quyền đăng bài viết lên Fanpage
        ],
      );

      // 3. XỬ LÝ KẾT QUẢ
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        debugPrint(
            "✅ Đăng nhập Facebook thành công! Token cấp độ cao nhất đã sẵn sàng.");

        // Trả token về cho tầng Repository để lưu trữ hoặc truyền sang FacebookSyncService
        return accessToken;
      } else if (result.status == LoginStatus.cancelled) {
        throw Exception("Người dùng đã hủy quá trình đăng nhập Facebook.");
      } else {
        throw Exception("Lỗi hệ thống đăng nhập Facebook: ${result.message}");
      }
    } catch (e) {
      debugPrint('❌ FacebookAuthDataSource Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await FacebookAuth.instance.logOut();
      debugPrint("✅ Đã đăng xuất Facebook.");
    } catch (e) {
      debugPrint('❌ Lỗi khi đăng xuất Facebook: $e');
      rethrow;
    }
  }
}