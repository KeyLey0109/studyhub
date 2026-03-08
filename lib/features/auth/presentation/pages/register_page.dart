import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import các thành phần của Auth Feature
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  // Bỏ tham số repository truyền vào để đồng bộ với main.dart
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isPasswordVisible = false;

  // 1. Hàm xử lý logic Đăng ký qua BLoC
  void _onRegisterPressed() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin!', Colors.orange);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Mật khẩu xác nhận không khớp!', Colors.red);
      return;
    }

    // Gửi sự kiện đăng ký tới AuthBloc thay vì gọi trực tiếp repository
    context.read<AuthBloc>().add(RegisterSubmitted(
      name: name,
      email: email,
      password: password,
    ));
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Tạo tài khoản",
          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // 2. Sử dụng BlocConsumer để lắng nghe kết quả đăng ký
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            _showSnackBar('Đăng ký thành công cho ${state.user.email}!', Colors.green);
            // Quay lại màn hình Login sau khi thành công
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) Navigator.pop(context);
            });
          } else if (state is AuthFailure) {
            _showSnackBar(state.message, Colors.red);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                children: [
                  const Icon(Icons.person_add_alt_1_rounded, size: 80, color: Colors.blue),
                  const SizedBox(height: 30),

                  _buildInput(_nameController, "Họ và tên", Icons.person_outline),
                  const SizedBox(height: 15),

                  _buildInput(
                      _emailController,
                      "Gmail",
                      Icons.email_outlined,
                      type: TextInputType.emailAddress
                  ),
                  const SizedBox(height: 15),

                  _buildInput(
                    _passwordController,
                    "Mật khẩu",
                    Icons.lock_outline,
                    isPass: true,
                    isVisible: _isPasswordVisible,
                    onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  const SizedBox(height: 15),

                  _buildInput(_confirmController, "Xác nhận mật khẩu", Icons.lock_reset, isPass: true),
                  const SizedBox(height: 40),

                  // Nút Đăng ký
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onRegisterPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                          : const Text('ĐĂNG KÝ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInput(
      TextEditingController controller,
      String label,
      IconData icon,
      {bool isPass = false, bool? isVisible, VoidCallback? onToggle, TextInputType? type}
      ) {
    return TextField(
      controller: controller,
      obscureText: isPass && !(isVisible ?? false),
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPass && onToggle != null
            ? IconButton(
          icon: Icon(isVisible! ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        // Dùng chuẩn mới thay .withOpacity
        fillColor: Colors.blue.withValues(alpha: 0.05),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}