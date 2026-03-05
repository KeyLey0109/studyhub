import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'injection_container.dart' as di;

// Import các Bloc
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/post/presentation/bloc/post_bloc.dart';
import 'features/post/presentation/bloc/post_event.dart';
import 'features/comment/presentation/bloc/comment_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/notifications/presentation/bloc/notification_event.dart';

// Import các trang giao diện
import 'features/auth/presentation/pages/login_page.dart';
import 'features/post/presentation/pages/root_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khóa hướng màn hình dọc để UI ổn định
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Khởi tạo Dependency Injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Khởi tạo Auth và check session ngay lập tức
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AppStarted()),
        ),
        // SỬA LỖI: Thêm dấu ngoặc đơn () để khởi tạo Event object
        BlocProvider<PostBloc>(
          create: (_) => di.sl<PostBloc>()..add(const LoadPosts()),
        ),
        BlocProvider<CommentBloc>(create: (_) => di.sl<CommentBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => di.sl<ProfileBloc>()),
        // SỬA LỖI: Khởi tạo instance của LoadNotifications()
        BlocProvider<NotificationBloc>(
          create: (_) => di.sl<NotificationBloc>()..add(const LoadNotifications()),
        ),
      ],
      child: MaterialApp(
        title: 'StudyHub',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(context),
        home: const AuthenticationWrapper(),
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1877F2),
        primary: const Color(0xFF1877F2),
      ),
      textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
      scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: GoogleFonts.roboto(
          color: const Color(0xFF1877F2),
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.2,
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 0.5,
        color: Colors.grey.withValues(alpha: 0.2),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          return const RootPage();
        } else if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1877F2)),
              ),
            ),
          );
        }
        return const LoginPage();
      },
    );
  }
}