import 'package:flutter/material.dart';
import '../../../../main.dart'; // Import để truy cập FakeAuthRepository và mockUsers

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 1. Khai báo các Controller để lấy dữ liệu nhập vào
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // 2. Hàm xử lý logic Đăng ký
  void _onRegisterPressed() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Kiểm tra bỏ trống
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin!', Colors.orange);
      return;
    }

    // Kiểm tra mật khẩu khớp nhau
    if (password != confirmPassword) {
      _showSnackBar('Mật khẩu xác nhận không khớp!', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    // Gọi hàm register từ FakeAuthRepository trong main.dart
    final result = await FakeAuthRepository().register(name, email, password);

    setState(() => _isLoading = false);

    result.fold(
          (error) => _showSnackBar(error, Colors.red),
          (user) {
        _showSnackBar('Đăng ký thành công tài khoản ${user.email}!', Colors.green);
        // Chờ 1 chút để người dùng kịp thấy thông báo rồi quay lại trang Login
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                // LOGO NHỎ
                const Icon(Icons.person_add_alt_1_rounded, size: 70, color: Colors.blue),
                const SizedBox(height: 10),
                const Text(
                  'Tạo tài khoản',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                const SizedBox(height: 30),

                // Ô NHẬP TÊN
                _buildTextField(_nameController, 'Họ và tên', Icons.person_outline),
                const SizedBox(height: 15),

                // Ô NHẬP GMAIL
                _buildTextField(_emailController, 'Gmail', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 15),

                // Ô NHẬP MẬT KHẨU
                _buildTextField(
                  _passwordController,
                  'Mật khẩu',
                  Icons.lock_outline,
                  isPassword: true,
                  isVisible: _isPasswordVisible,
                  toggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                const SizedBox(height: 15),

                // Ô NHẬP LẠI MẬT KHẨU
                _buildTextField(_confirmPasswordController, 'Xác nhận mật khẩu', Icons.lock_reset, isPassword: true),
                const SizedBox(height: 30),

                // NÚT ĐĂNG KÝ
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onRegisterPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ĐĂNG KÝ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Đã có tài khoản? "),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Đăng nhập ngay', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget dùng chung cho các ô nhập liệu
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      {bool isPassword = false, bool? isVisible, VoidCallback? toggleVisibility, TextInputType? keyboardType}
      ) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !(isVisible ?? false),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword && toggleVisibility != null
            ? IconButton(icon: Icon(isVisible! ? Icons.visibility : Icons.visibility_off), onPressed: toggleVisibility)
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}