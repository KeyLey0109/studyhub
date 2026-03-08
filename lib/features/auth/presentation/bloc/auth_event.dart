abstract class AuthEvent {}

// Sự kiện đăng nhập đã có
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  LoginSubmitted(this.email, this.password);
}

// THÊM VÀO: Sự kiện đăng ký để fix lỗi image_0152fe
class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;

  RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });
}