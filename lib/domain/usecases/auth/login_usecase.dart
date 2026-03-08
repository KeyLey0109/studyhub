import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<UserEntity> call({required String emailOrPhone, required String password}) =>
      repository.login(emailOrPhone: emailOrPhone, password: password);
}

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<UserEntity> call({
    required String name,
    required String emailOrPhone,
    required String password,
  }) => repository.register(name: name, emailOrPhone: emailOrPhone, password: password);
}

class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<void> call() => repository.logout();
}
