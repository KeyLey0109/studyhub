import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(AuthInitial()) {

    // 1. Xử lý Đăng nhập (Đổi từ LoginSubmitted thành LoginRequested)
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading()); // Hiển thị vòng xoay chờ

      final result = await loginUseCase(event.email, event.password);

      result.fold(
            (error) => emit(AuthFailure(error)), // Thông báo lỗi nếu sai pass/email
            (user) => emit(AuthSuccess(user)),   // Đăng nhập thành công, trả về UserEntity
      );
    });

    // 2. Xử lý Đăng ký (Đổi từ RegisterSubmitted thành RegisterRequested)
    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());

      final result = await registerUseCase(
        name: event.name,
        email: event.email,
        password: event.password,
      );

      result.fold(
            (error) => emit(AuthFailure(error)), // Hiển thị lỗi từ FakeAuthDataSource
            (user) => emit(AuthSuccess(user)),   // Đăng ký xong, tự động đăng nhập luôn
      );
    });

    // 3. Xử lý Đăng xuất
    on<LogoutRequested>((event, emit) {
      emit(AuthInitial()); // Quay lại trạng thái ban đầu để hiện màn hình Login
    });
  }
}