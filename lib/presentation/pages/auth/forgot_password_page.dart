import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _ctrl = TextEditingController();
  bool _loading = false, _sent = false;

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Quên mật khẩu'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey, borderRadius: BorderRadius.circular(50)),
          child: const Icon(Icons.lock_reset, size: 48, color: AppTheme.primaryBlue),
        ),
      ),
      const SizedBox(height: 24),
      const Text('Đặt lại mật khẩu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Nhập email hoặc số điện thoại đã đăng ký để nhận hướng dẫn đặt lại mật khẩu.',
        style: TextStyle(color: AppTheme.textGrey)),
      const SizedBox(height: 24),
      TextField(
        controller: _ctrl,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email hoặc số di động',
          prefixIcon: Icon(Icons.alternate_email)),
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: _loading ? null : _reset,
        child: _loading
            ? const SizedBox(height: 20, width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Tiếp tục'),
      ),
    ],
  );

  Widget _buildSuccess() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_read, size: 80, color: Colors.green),
        const SizedBox(height: 24),
        const Text('Đã gửi hướng dẫn!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Chúng tôi đã gửi hướng dẫn đặt lại mật khẩu đến ${_ctrl.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textGrey)),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => context.go('/login'),
          child: const Text('Quay về đăng nhập'),
        ),
      ],
    ),
  );

  Future<void> _reset() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _loading = false; _sent = true; });
  }
}
