import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../bloc/post_state.dart';
import '../widgets/post_card.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showCreatePostSheet(BuildContext context) {
    final contentController = TextEditingController();
    final ImagePicker picker = ImagePicker();
    File? selectedImage;
    File? selectedVideo;

    // 1. Lấy thông tin user hiện tại từ AuthBloc để gán tên người đăng
    final authState = context.read<AuthBloc>().state;
    String currentUserName = "Sinh viên PYU";
    if (authState is AuthSuccess) {
      currentUserName = authState.user.name; // Tên thật từ lúc đăng ký
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Đăng bài với tên: $currentUserName",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  hintText: "Bạn đang nghiên cứu gì thế?",
                  border: InputBorder.none,
                ),
                maxLines: 3,
              ),

              // Xem trước Ảnh
              if (selectedImage != null)
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(selectedImage!, fit: BoxFit.cover),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => setSheetState(() => selectedImage = null),
                    ),
                  ],
                ),

              // Xem trước Video
              if (selectedVideo != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.movie_creation_outlined, color: Colors.blue),
                      const SizedBox(width: 10),
                      const Expanded(child: Text("Đã chọn 1 video")),
                      GestureDetector(
                        onTap: () => setSheetState(() => selectedVideo = null),
                        child: const Icon(Icons.cancel, color: Colors.grey),
                      )
                    ],
                  ),
                ),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.green),
                    onPressed: () async {
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setSheetState(() {
                          selectedImage = File(image.path);
                          selectedVideo = null;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.video_call, color: Colors.red),
                    onPressed: () async {
                      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
                      if (video != null) {
                        setSheetState(() {
                          selectedVideo = File(video.path);
                          selectedImage = null;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final content = contentController.text.trim();
                  if (content.isNotEmpty || selectedImage != null || selectedVideo != null) {

                    // 2. Truyền userName thật vào Event AddPost
                    context.read<PostBloc>().add(AddPost(
                      content: content,
                      userName: currentUserName,
                      image: selectedImage,
                      video: selectedVideo,
                    ));

                    Navigator.pop(context);
                  }
                },
                child: const Text("ĐĂNG BÀI",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('StudyHub',
            style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
          ),
        ],
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostLoaded) {
            if (state.posts.isEmpty) {
              return const Center(child: Text("Chưa có bài viết nào. Hãy chia sẻ kiến thức nhé!"));
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<PostBloc>().add(const LoadPosts()),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: state.posts.length,
                itemBuilder: (context, index) => PostCard(post: state.posts[index]),
              ),
            );
          } else if (state is PostError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${state.message}', style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: () => context.read<PostBloc>().add(const LoadPosts()),
                    child: const Text("Tải lại"),
                  )
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostSheet(context),
        label: const Text("Chia sẻ"),
        icon: const Icon(Icons.add_comment),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}