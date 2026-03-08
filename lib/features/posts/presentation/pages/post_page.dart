import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Đảm bảo import đúng các file Bloc để tránh lỗi "isn't defined"
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../bloc/post_state.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  void initState() {
    super.initState();
    // Tự động kích hoạt tải bài viết khi khởi tạo trang
    context.read<PostBloc>().add(LoadPostsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bảng tin StudyHub", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      // Sử dụng BlocBuilder để lắng nghe trạng thái từ PostBloc
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostLoaded) {
            return RefreshIndicator(
              onRefresh: () async => context.read<PostBloc>().add(LoadPostsEvent()),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return _buildPostCard(post);
                },
              ),
            );
          } else if (state is PostError) {
            // Hiển thị lỗi từ PostState.message
            return Center(
              child: Text(state.message, style: const TextStyle(color: Colors.red)),
            );
          }
          return const Center(child: Text("Chưa có bài viết nào được đăng."));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logic điều hướng đến trang tạo bài viết mới của Việt
        },
        child: const Icon(Icons.edit_note_rounded),
      ),
    );
  }

  // Widget thẻ bài viết tối giản (Không còn nút hay danh sách bình luận)
  Widget _buildPostCard(dynamic post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1), // Chuẩn mới
                  child: Text(post.authorName[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const Text("Vừa xong", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              post.content,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}