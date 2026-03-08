import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String emailOrPhone, required String password});
  Future<UserEntity> register({
    required String name,
    required String emailOrPhone,
    required String password,
  });
  Future<void> logout();
  Future<bool> resetPassword({required String emailOrPhone});
  Future<UserEntity?> getCurrentUser();
  Future<List<UserEntity>> getAllUsers();
  Future<UserEntity?> getUserById(String id);
  Future<void> updateUser(UserEntity user);
}
