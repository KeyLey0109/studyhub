import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  /// Lấy dữ liệu profile từ Server/Firebase
  Future<ProfileModel> getProfile(String userId);

  /// Cập nhật thông tin cá nhân: tên, ngày sinh, tiểu sử, ảnh
  Future<void> updateProfile({
    required String name,
    DateTime? birthDate,
    String? bio,
    String? avatarUrl,
  });

  /// Xử lý gửi hoặc hủy lời mời kết bạn
  Future<void> toggleFriendRequest(String targetUserId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  // Giả sử Việt dùng FirebaseFirestore hoặc HttpClient (Dio/Http)
  // final FirebaseFirestore firestore;
  // ProfileRemoteDataSourceImpl({required this.firestore});

  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      // Trong thực tế, Việt sẽ viết:
      // final doc = await firestore.collection('users').doc(userId).get();
      // return ProfileModel.fromJson(doc.data()!, userId);

      // Đây là dữ liệu giả lập để Việt chạy thử giao diện:
      return ProfileModel(
        userId: userId,
        userName: "Sinh viên PYU",
        email: "viet.student@pyu.edu.vn", // Gmail đăng ký
        birthDate: DateTime(2004, 1, 1),
        bio: "Đang học tại Đại học Phú Yên",
        avatarUrl: null,
        isFriend: false,
        isPending: false,
      );
    } catch (e) {
      throw Exception("Lỗi khi kết nối Server: $e");
    }
  }

  @override
  Future<void> updateProfile({
    required String name,
    DateTime? birthDate,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      // Logic cập nhật dữ liệu lên Firebase/API
      // await firestore.collection('users').doc(currentUserId).update({ ... });
    } catch (e) {
      throw Exception("Không thể cập nhật thông tin cá nhân");
    }
  }

  @override
  Future<void> toggleFriendRequest(String targetUserId) async {
    try {
      // Logic gửi lời mời kết bạn phong cách Facebook
      // Thêm userId của mình vào mảng friendRequests của đối phương
    } catch (e) {
      throw Exception("Lỗi thao tác kết bạn");
    }
  }
}