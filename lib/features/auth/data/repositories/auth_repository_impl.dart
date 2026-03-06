import 'package:dartz/dartz.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/fake_auth_data_source.dart'; // Dùng DataSource thay vì main.dart

class AuthRepositoryImpl implements AuthRepository {
  final FakeAuthDataSource fakeDataSource;

  // Constructor nhận fakeDataSource từ main.dart truyền vào
  AuthRepositoryImpl({required this.fakeDataSource});

  @override
<<<<<<< HEAD
  Future<Either<String, UserEntity>> login(
      String email, String password) async {
=======
  Future<Either<String, UserEntity>> login(String email, String password) async {
>>>>>>> origin/feature
    try {
      // Gọi logic từ FakeAuthDataSource
      final userData = await fakeDataSource.login(email, password);

      // Chuyển đổi dữ liệu từ Map sang Entity (Giả sử bạn đã có UserEntity)
      return Right(UserEntity(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
      ));
    } catch (e) {
      // Trả về thông báo lỗi cụ thể từ DataSource
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, UserEntity>> register(
      String name, String email, String password) async {
    try {
<<<<<<< HEAD
      final newUser = await fakeDataSource.register(name, email, password);

      // Sau khi đăng ký thành công, trả về một Entity thực
      return Right(UserEntity(id: newUser['id']!, name: name, email: email));
=======
      await fakeDataSource.register(name, email, password);

      // Sau khi đăng ký thành công, trả về một Entity tạm thời
      return Right(UserEntity(id: 'temp', name: name, email: email));
>>>>>>> origin/feature
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() async {
<<<<<<< HEAD
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
=======

    await Future.delayed(const Duration(milliseconds: 500));
  }
}
>>>>>>> origin/feature
