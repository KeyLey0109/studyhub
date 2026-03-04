class FakeAuthDataSource {
  // Giả lập danh sách tài khoản trong hệ thống
  final List<Map<String, String>> _fakeUsers = [
    {'email': 'viet@pyu.edu.vn', 'password': '123', 'name': 'Việt'},
    {'email': 'admin@studyhub.com', 'password': 'admin', 'name': 'Admin'},
  ];

  /// Giả lập việc gọi API đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {

    await Future.delayed(const Duration(seconds: 1));

    for (var user in _fakeUsers) {
      if (user['email'] == email && user['password'] == password) {
        return {
          'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
          'name': user['name'],
          'email': user['email'],
          'token': 'fake_jwt_token_for_studyhub',
        };
      }
    }

    throw Exception('Email hoặc mật khẩu không chính xác!');
  }

  Future<void> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Kiểm tra xem email đã tồn tại chưa
    if (_fakeUsers.any((u) => u['email'] == email)) {
      throw Exception('Email này đã được sử dụng!');
    }

    _fakeUsers.add({
      'name': name,
      'email': email,
      'password': password,
    });
  }
}