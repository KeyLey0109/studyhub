import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<String, UserEntity>> login(String email, String password) async {
    try {
      // Giả lập gọi API (Fake API)
      await Future.delayed(const Duration(seconds: 1));
      if (email == "admin@studyhub.com" && password == "123456") {
        return const Right(UserEntity(id: "1", name: "Admin", email: "admin@studyhub.com"));
      }
      return const Left("Sai tài khoản hoặc mật khẩu");
    } catch (e) {
      return Left(e.toString());
    }
  }
}