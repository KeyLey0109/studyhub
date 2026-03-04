import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc({required this.loginUseCase}) : super(AuthInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      // Giả lập delay 1 giây để thấy vòng xoay Loading trên Android
      await Future.delayed(const Duration(seconds: 1));
      final result = await loginUseCase(event.email, event.password);
      result.fold(
            (failure) => emit(AuthFailure(failure)),
            (user) => emit(AuthSuccess(user)),
      );
    });
  }
}