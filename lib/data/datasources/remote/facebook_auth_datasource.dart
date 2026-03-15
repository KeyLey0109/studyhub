import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

abstract class FacebookAuthDataSource {
  /// Thực hiện luồng đăng nhập Facebook CƠ BẢN (chỉ lấy Tên, Avatar, Email)
  Future<AccessToken> loginWithFacebook();

  /// Yêu cầu thêm quyền nâng cao (Lấy bài viết, Quản lý Fanpage)
  Future<AccessToken> requestAdvancedPermissions();

  /// Đăng xuất khỏi Facebook
  Future<void> logout();
}

class FacebookAuthDataSourceImpl implements FacebookAuthDataSource {
  @override
  Future<AccessToken> loginWithFacebook() async {
    try {
      // 1. BẮT BUỘC CHO iOS: Xin quyền Tracking để tránh "Limited Login"
      if (Platform.isIOS) {
        final TrackingStatus status =
            await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('Trạng thái cấp quyền iOS (ATT): $status');
        // Dù người dùng cho phép hay từ chối, luồng vẫn đi tiếp.
      }

      // 2. GỌI SDK ĐĂNG NHẬP: CHỈ XIN QUYỀN CƠ BẢN (Sửa lỗi Invalid Scope)
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: [
          'email',
          'public_profile',
        ],
      );

      // 3. XỬ LÝ KẾT QUẢ
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        debugPrint("✅ Đăng nhập Facebook thành công với quyền cơ bản!");
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
  Future<AccessToken> requestAdvancedPermissions() async {
    try {
      // Gọi SDK một lần nữa nhưng xin các quyền nâng cao để làm việc với Fanpage
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['user_posts', 'pages_show_list', 'pages_manage_posts'],
      );

      if (result.status == LoginStatus.success) {
        debugPrint("✅ Đã cấp thêm quyền nâng cao thành công!");
        return result.accessToken!;
      } else if (result.status == LoginStatus.cancelled) {
        throw Exception("Người dùng từ chối cấp quyền nâng cao.");
      } else {
        throw Exception("Lỗi hệ thống khi xin quyền: ${result.message}");
      }
    } catch (e) {
      debugPrint('❌ requestAdvancedPermissions Error: $e');
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