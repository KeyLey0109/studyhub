import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/hive_local_datasource.dart';
import '../datasources/remote/fake_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FakeRemoteDatasource remote;
  final HiveLocalDatasource local;
  AuthRepositoryImpl({required this.remote, required this.local});

  @override Future<UserEntity> login({required String emailOrPhone, required String password}) async {
    final user = await remote.login(emailOrPhone, password);
    await local.setCurrentUserId(user.id);
    return user;
  }

  @override Future<UserEntity> register({
    required String name, required String emailOrPhone, required String password,
  }) async {
    final user = await remote.register(name: name, emailOrPhone: emailOrPhone, password: password);
    await local.setCurrentUserId(user.id);
    return user;
  }

  @override Future<void> logout() => local.clearCurrentUser();

  @override Future<bool> resetPassword({required String emailOrPhone}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return local.getUserByEmailOrPhone(emailOrPhone) != null;
  }

  @override Future<UserEntity?> getCurrentUser() async {
    final id = local.getCurrentUserId();
    if (id == null) return null;
    return local.getUserById(id);
  }

  @override Future<List<UserEntity>> getAllUsers() async => local.getAllUsers();
  @override Future<UserEntity?> getUserById(String id) async => local.getUserById(id);
  @override Future<void> updateUser(UserEntity user) => local.saveUser(user);
}
