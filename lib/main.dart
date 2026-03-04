import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORT TẦNG AUTH ---
import 'features/auth/data/datasources/fake_auth_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';

// --- IMPORT TẦNG POST ---
import 'features/post/data/datasources/post_local_data_source.dart';
import 'features/post/data/repositories/post_repository_impl.dart';
import 'features/post/domain/usecases/get_post_usecase.dart';
import 'features/post/domain/usecases/create_post_usecase.dart';
import 'features/post/presentation/bloc/post_bloc.dart';
import 'features/post/presentation/bloc/post_event.dart';
import 'features/post/presentation/pages/home_page.dart';

// --- IMPORT TẦNG COMMENT (Mới thêm) ---
import 'features/comment/data/repositories/comment_repository_impl.dart';
import 'features/comment/domain/usecases/add_comment_usecase.dart';
import 'features/comment/presentation/bloc/comment_bloc.dart';

void main() async {
  // 1. Khởi tạo các dịch vụ nền tảng
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  // 2. Khởi tạo Data Sources & Repositories
  final authDataSource = FakeAuthDataSource();
  final authRepository = AuthRepositoryImpl(fakeDataSource: authDataSource);

  final postLocalDataSource = PostLocalDataSourceImpl(sharedPreferences: sharedPreferences);
  final postRepository = PostRepositoryImpl(localDataSource: postLocalDataSource);

  // Khởi tạo Repository cho Comment (Dùng chung DataSource của Post để lưu vào cùng một nơi)
  final commentRepository = CommentRepositoryImpl(localDataSource: postLocalDataSource);

  // 3. Khởi tạo UseCases
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final getPostsUseCase = GetPostsUseCase(postRepository);
  final createPostUseCase = CreatePostUseCase(postRepository);

  // UseCase cho Comment
  final addCommentUseCase = AddCommentUseCase(commentRepository);

  runApp(MyApp(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    getPostsUseCase: getPostsUseCase,
    createPostUseCase: createPostUseCase,
    addCommentUseCase: addCommentUseCase, // Truyền vào MyApp
  ));
}

class MyApp extends StatelessWidget {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetPostsUseCase getPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final AddCommentUseCase addCommentUseCase;

  const MyApp({
    super.key,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getPostsUseCase,
    required this.createPostUseCase,
    required this.addCommentUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 1. AuthBloc: Quản lý phiên đăng nhập của sinh viên PYU
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
          ),
        ),

        // 2. PostBloc: Quản lý bài viết và tương tác Like
        BlocProvider<PostBloc>(
          create: (context) => PostBloc(
            getPostsUseCase: getPostsUseCase,
            createPostUseCase: createPostUseCase,
            authBloc: BlocProvider.of<AuthBloc>(context),
          )..add(const LoadPosts()),
        ),

        // 3. CommentBloc: Xử lý bình luận đa tầng (Cần AuthBloc để biết ai đang comment)
        BlocProvider<CommentBloc>(
          create: (context) => CommentBloc(
            addCommentUseCase: addCommentUseCase,
            authBloc: BlocProvider.of<AuthBloc>(context),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'StudyHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color.fromARGB(255, 240, 242, 245),
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              return const HomePage();
            }
            return const LoginPage();
          },
        ),
      ),
    );
  }
}