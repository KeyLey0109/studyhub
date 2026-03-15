import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/hive_local_datasource.dart';
import '../datasources/remote/supabase_remote_datasource.dart';
import '../datasources/remote/facebook_auth_datasource.dart'; // ✅ Import file mới

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseRemoteDatasource remote;
  final HiveLocalDatasource local;
  final FacebookAuthDataSource facebookAuth; // ✅ Thêm Data Source của Facebook

  AuthRepositoryImpl({
    required this.remote,
    required this.local,
    required this.facebookAuth,
  });

  @override
  Future<UserEntity> login(
      {required String emailOrPhone, required String password}) async {
    final user = await remote.signIn(emailOrPhone, password);
    await local.setCurrentUserId(user.id);
    await local.saveUser(user); // Cache lại thông tin user
    return user;
  }

  // ✅ HÀM MỚI: Xử lý Đăng nhập bằng Facebook
  @override
  Future<UserEntity> loginWithFacebook() async {
    try {
      // 1. Gọi FacebookAuthDataSource để xin Token (đã xử lý chống Limited Login)
      final accessToken = await facebookAuth.loginWithFacebook();

      // 2. Gửi Token này lên Supabase để Supabase xác thực và trả về UserEntity
      // (Bạn sẽ cần thêm hàm signInWithFacebookToken vào SupabaseRemoteDatasource)
      final user =
          await remote.signInWithFacebookToken(accessToken.tokenString);

      // 3. Lưu vào Local Cache (Hive) để dùng offline
      await local.setCurrentUserId(user.id);
      await local.saveUser(user);

      return user;
    } catch (e) {
      debugPrint('Lỗi Repository khi đăng nhập Facebook: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String emailOrPhone,
    required String password,
  }) async {
    final user = await remote.register(name, emailOrPhone, password);
    await local.setCurrentUserId(user.id);
    await local.saveUser(user); // Cache lại
    return user;
  }

  @override
  Future<void> logout() async {
    // ✅ Đăng xuất toàn diện ở cả 3 nền tảng
    await facebookAuth.logout(); // Đăng xuất khỏi Facebook SDK
    await remote.signOut(); // Đăng xuất khỏi Supabase (nếu có hàm này)
    await local.clearCurrentUser(); // Xóa dữ liệu ở Hive
  }

  @override
  Future<bool> resetPassword({required String emailOrPhone}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return local.getUserByEmailOrPhone(emailOrPhone) != null;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final id = local.getCurrentUserId();
    if (id == null) return null;

    // Always fetch fresh from remote to get latest avatar/cover/bio
    try {
      final freshUser = await remote.getUserById(id);
      if (freshUser != null) {
        await local.saveUser(freshUser); // Cache it
      }
      return freshUser;
    } catch (_) {
      // Fallback to local if offline or error
      return local.getUserById(id);
    }
  }

  @override
  Future<List<UserEntity>> getAllUsers() async =>
      remote.getSuggestions(local.getCurrentUserId() ?? '');

  @override
  Future<UserEntity?> getUserById(String id) async {
    try {
      final user = await remote.getUserById(id);
      if (user != null) {
        await local.saveUser(user);
      }
      return user;
    } catch (_) {
      return local.getUserById(id);
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    // Usually handled by specific remote methods like updateAvatar, updateBio etc.
    // For now we just sync it to local cache to reflect immediately on UI.
    await local.saveUser(user);
  }
}
