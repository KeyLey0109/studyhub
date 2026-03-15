import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart'; // Đảm bảo import đúng
import '../../../domain/usecases/auth/logout_usecase.dart'; // Đảm bảo import đúng
import '../../../data/datasources/local/hive_local_datasource.dart';
import '../../../data/datasources/remote/supabase_remote_datasource.dart';
import '../../../data/datasources/remote/facebook_auth_datasource.dart'; // ✅ Import DataSource FB mới
import '../../../injection_container.dart' as di;

// ==========================================
// EVENTS
// ==========================================
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String emailOrPhone;
  final String password;
  LoginEvent(this.emailOrPhone, this.password);
  @override
  List<Object?> get props => [emailOrPhone, password];
}

class RegisterEvent extends AuthEvent {
  final String name, emailOrPhone, password;
  RegisterEvent(this.name, this.emailOrPhone, this.password);
  @override
  List<Object?> get props => [name, emailOrPhone, password];
}

class LogoutEvent extends AuthEvent {}

class FacebookLoginEvent extends AuthEvent {}

class SyncDataEvent extends AuthEvent {
  final String userId;
  SyncDataEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class UpdateUserEvent extends AuthEvent {
  final UserEntity user;
  UpdateUserEvent(this.user);
  @override
  List<Object?> get props => [user];
}

// ==========================================
// STATES
// ==========================================
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// ==========================================
// BLoC
// ==========================================
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final HiveLocalDatasource local;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.local,
  }) : super(AuthInitial()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<UpdateUserEvent>(_onUpdateUser);
    on<SyncDataEvent>(_onSyncData);
    on<FacebookLoginEvent>(_onFacebookLogin);
  }

  Future<void> _onSyncData(SyncDataEvent event, Emitter<AuthState> emit) async {
    try {
      final remote = di.sl<SupabaseRemoteDatasource>();
      final posts =
          local.getAllPosts().where((p) => p.authorId == event.userId);
      for (var p in posts) {
        if (!p.id.startsWith('welcome')) {
          try {
            await remote.createPost(
              authorId: p.authorId,
              authorName: p.authorName,
              authorAvatar: p.authorAvatar,
              content: p.content,
              mediaUrls: p.mediaUrls,
              mediaTypes: p.mediaTypes,
            );
          } catch (_) {}
        }
      }

      final allUsers = local.getAllUsers();
      for (var otherUser in allUsers) {
        if (otherUser.id == event.userId) continue;
        final msgs = local.getMessagesBetween(event.userId, otherUser.id);
        for (var m in msgs) {
          try {
            await remote.sendMessage(m.senderId, m.receiverId, m.content);
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Sync error: $e');
    }
  }

  Future<void> _onCheckAuth(
      CheckAuthEvent event, Emitter<AuthState> emit) async {
    final id = local.getCurrentUserId();
    if (id != null) {
      // First emit local for fast UI
      final localUser = local.getUserById(id);
      if (localUser != null) {
        emit(AuthAuthenticated(localUser));
      }

      // Then fetch fresh data in background to stay in sync
      try {
        final remote = di.sl<SupabaseRemoteDatasource>();
        final freshUser = await remote.getUserById(id);
        if (freshUser != null) {
          await local.saveUser(freshUser);
          if (!isClosed) {
            emit(AuthAuthenticated(freshUser));
          }
        }
        return;
      } catch (e) {
        debugPrint('Auth Check Error sync: $e');
        if (localUser != null) return; // stick to local if remote fails
      }
    }
    emit(AuthUnauthenticated());
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(
          emailOrPhone: event.emailOrPhone, password: event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase(
        name: event.name,
        emailOrPhone: event.emailOrPhone,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await logoutUseCase();

    // Đảm bảo token FB cũng được xóa sạch khi đăng xuất
    try {
      final fbAuth = di.sl<FacebookAuthDataSource>();
      await fbAuth.logout();
    } catch (_) {}

    emit(AuthUnauthenticated());
  }

  void _onUpdateUser(UpdateUserEvent event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user));
  }

  // ✅ HÀM ĐÃ ĐƯỢC CẬP NHẬT CHUẨN KIẾN TRÚC
  Future<void> _onFacebookLogin(
      FacebookLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // BƯỚC 1: Gọi DataSource xử lý an toàn (có xin quyền iOS và đầy đủ quyền API)
      final fbDataSource = di.sl<FacebookAuthDataSource>();
      final accessToken = await fbDataSource.loginWithFacebook();

      // Lưu Token để file FacebookSyncService lấy bài viết/đăng bài sau này
      local.saveFbAccessToken(accessToken.tokenString);

      // BƯỚC 2: Lấy thông tin user từ Facebook
      final userData = await FacebookAuth.instance.getUserData(
        fields: 'name,email,picture.width(200)',
      );

      final String fbId = userData['id'] ?? '';
      final String fbName = userData['name'] ?? 'Facebook User';
      final String fbEmail = userData['email'] ?? '$fbId@facebook.com';
      final String? fbAvatar = userData['picture']?['data']?['url'];

      // BƯỚC 3: Đồng bộ Local và Remote (Giữ nguyên logic của bạn)
      final allUsers = local.getAllUsers();
      UserEntity? existingUser;
      for (final u in allUsers) {
        if (u.email == fbEmail) {
          existingUser = u;
          break;
        }
      }

      final remote = di.sl<SupabaseRemoteDatasource>();

      if (existingUser != null) {
        // Cập nhật user cũ
        final updated = existingUser.copyWith(
          avatarUrl: fbAvatar ?? existingUser.avatarUrl,
          name: existingUser.name.isEmpty ? fbName : existingUser.name,
        );
        await local.saveUser(updated);
        await local.setCurrentUserId(updated.id);

        await remote.upsertUser(updated); // Sync lên DB

        emit(AuthAuthenticated(updated));
      } else {
        // Tạo user mới
        final newUser = UserEntity(
          id: 'fb_$fbId',
          name: fbName,
          email: fbEmail,
          avatarUrl: fbAvatar,
          createdAt: DateTime.now(),
        );
        await local.saveUser(newUser);
        await local.setCurrentUserId(newUser.id);

        await remote.upsertUser(newUser); // Sync lên DB

        emit(AuthAuthenticated(newUser));
      }
    } catch (e) {
      debugPrint('Facebook Login Error: $e');
      emit(AuthError(
          'Lỗi đăng nhập Facebook: ${e.toString().replaceAll('Exception: ', '')}'));
    }
  }
}