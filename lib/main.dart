import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/posts/data/repositories/post_repository_impl.dart';
import 'features/posts/presentation/bloc/post_bloc.dart';
import 'features/posts/presentation/pages/post_page.dart';

void main() {
  final repository = PostRepositoryImpl();

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final PostRepositoryImpl repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => PostBloc(repository),
        child: const PostPage(),
import 'package:dartz/dartz.dart';

// Import các thành phần của tính năng Auth
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/entities/user_entity.dart';

// 1. DATABASE GIẢ LẬP (MOCK DATA)
// Biến này để ở ngoài Class để cả Login và Register đều có thể truy cập và chỉnh sửa
List<Map<String, String>> mockUsers = [
  {
    "email": "admin@studyhub.com",
    "password": "123456",
    "name": "Admin StudyHub"
  }
];

// 2. REPOSITORY XỬ LÝ LOGIC
class FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<String, UserEntity>> login(String email, String password) async {
    // Giả lập độ trễ mạng
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Tìm kiếm tài khoản trong danh sách mockUsers
      final user = mockUsers.firstWhere(
            (u) => u['email'] == email && u['password'] == password,
      );

      return Right(UserEntity(
          id: email,
          name: user['name']!,
          email: email
      ));
    } catch (e) {
      // Nếu không tìm thấy tài khoản phù hợp
      return const Left("Gmail hoặc mật khẩu không chính xác!");
    }
  }

  // Hàm hỗ trợ Đăng ký (được gọi từ RegisterPage)
  Future<Either<String, UserEntity>> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Kiểm tra nếu email đã tồn tại trong hệ thống
    if (mockUsers.any((u) => u['email'] == email)) {
      return const Left("Email này đã được đăng ký trước đó!");
    }

    // Thêm thành viên mới vào danh sách mock
    mockUsers.add({
      "email": email,
      "password": password,
      "name": name
    });

    return Right(UserEntity(id: email, name: name, email: email));
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudyHubApp());
}

class StudyHubApp extends StatelessWidget {
  const StudyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo Repository và UseCase
    final authRepository = FakeAuthRepository();
    final loginUseCase = LoginUseCase(authRepository);

    return MaterialApp(
      title: 'StudyHub',
      debugShowCheckedModeBanner: false,

      // Cấu hình Theme chuẩn Material 3 (Màu xanh Blue)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),

      // Cung cấp AuthBloc cho toàn bộ ứng dụng
      home: BlocProvider(
        create: (context) => AuthBloc(loginUseCase: loginUseCase),
        child: const LoginPage(),
      ),
    );
  }
}