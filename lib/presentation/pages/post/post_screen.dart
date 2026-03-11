import 'package:flutter/material.dart';
import '../../../data/services/facebook_api.dart'; 

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  void _handlePost() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    // 1. Tự động đẩy lên Fanpage Facebook ngầm
    bool success = await FacebookApi.postToFanpage(_controller.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Đã đăng lên Fanpage TAROT TO KEY!'),
          backgroundColor: Colors.green,
        ),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('😟 Có lỗi xảy ra khi đăng lên Facebook.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đăng bài lên Fanpage', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Bạn muốn chia sẻ điều gì lên Fanpage TAROT TO KEY?',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading 
              ? const CircularProgressIndicator(color: Color(0xFF1877F2)) 
              : ElevatedButton.icon(
                  onPressed: _handlePost,
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  label: const Text('ĐĂNG BÀI NGAY', 
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
            const SizedBox(height: 16),
            const Text(
              'Bài viết sẽ được đăng trực tiếp lên Fanpage Facebook.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
} 
