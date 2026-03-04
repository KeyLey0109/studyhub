import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studyhub/features/auth/domain/entities/user_entity.dart';
import 'package:studyhub/features/auth/domain/repositories/auth_repository.dart';
import 'package:studyhub/features/auth/domain/usecases/login_usecase.dart';

// 1. Tạo Mock Repository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUseCase(mockRepository);
  });

  const tUser = UserEntity(id: '1', name: 'Admin', email: 'admin@studyhub.com');

  test('nên trả về UserEntity khi đăng nhập thành công', () async {
    // Arrange
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => const Right(tUser));
    // Act
    final result = await usecase("admin@studyhub.com", "123456");
    // Assert
    expect(result, const Right(tUser));
  });
}