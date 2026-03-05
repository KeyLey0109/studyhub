import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// --- IMPORT CỰC KỲ QUAN TRỌNG ĐỂ HẾT LỖI GẠCH ĐỎ ---
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../bloc/post_state.dart';
import '../widgets/post_card.dart';

// Đảm bảo đường dẫn này trỏ đúng đến nơi có LogoutRequested
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

// Đảm bảo đường dẫn này trỏ đúng đến nơi có LoadNotifications
import '../../../notifications/presentation/pages/notification_screen.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';

import '../../../profile/presentation/pages/profile_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final String uName = (authState is AuthSuccess) ? authState.user.name : "Sinh viên";

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: RefreshIndicator(
        onRefresh: () async {
          // Thêm const để khớp với định nghĩa trong PostEvent
          context.read<PostBloc>().add(const LoadPosts());
          // THÊM CONST Ở ĐÂY ĐỂ HẾT LỖI "ISN'T A CLASS"
          context.read<NotificationBloc>().add(const LoadNotifications());
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context, authState),
            SliverToBoxAdapter(child: _buildStatusHeader(context, uName)),
            _buildCreatingIndicator(),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            _buildPostList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatingIndicator() {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostLoaded && state.isCreating) {
          return const SliverToBoxAdapter(
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1877F2)),
              minHeight: 2,
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  void _showCreatePostSheet(BuildContext context, String uName) {
    final TextEditingController controller = TextEditingController();
    File? selectedImage;
    File? selectedVideo;
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16, right: 16, top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Tạo bài viết mới", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  TextField(
                    controller: controller,
                    maxLines: 5,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "Bạn đang nghiên cứu gì thế?",
                      border: InputBorder.none,
                    ),
                  ),
                  if (selectedImage != null || selectedVideo != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        selectedImage != null ? "📸 Đã chọn 1 ảnh" : "🎥 Đã chọn 1 video",
                        style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) setModalState(() => selectedImage = File(image.path));
                        },
                        icon: const Icon(Icons.photo_library, color: Colors.green),
                      ),
                      IconButton(
                        onPressed: () async {
                          final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
                          if (video != null) setModalState(() => selectedVideo = File(video.path));
                        },
                        icon: const Icon(Icons.videocam, color: Colors.red),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty || selectedImage != null || selectedVideo != null) {
                            context.read<PostBloc>().add(
                              CreatePostRequested(
                                content: controller.text.trim(),
                                userName: uName,
                                image: selectedImage,
                                video: selectedVideo,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1877F2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Đăng bài", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AuthState authState) {
    return SliverAppBar(
      floating: true,
      elevation: 0.5,
      backgroundColor: Colors.white,
      title: const Text(
        'StudyHub',
        style: TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold, fontSize: 28),
      ),
      actions: [
        _buildCircleAction(Icons.search, Colors.black, () {}),
        _buildNotificationAction(context),
        _buildUserMenu(context, authState),
      ],
    );
  }

  Widget _buildUserMenu(BuildContext context, AuthState authState) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'profile' && authState is AuthSuccess) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: authState.user.id, isCurrentUser: true)));
        } else if (value == 'logout') {
          // SỬA DÒNG NÀY ĐỂ HẾT LỖI "ISN'T DEFINED"
          context.read<AuthBloc>().add(LogoutRequested());
        }
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: CircleAvatar(radius: 18, child: Icon(Icons.person)),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'profile', child: Text("Trang cá nhân")),
        const PopupMenuItem(value: 'logout', child: Text("Đăng xuất", style: TextStyle(color: Colors.red))),
      ],
    );
  }

  Widget _buildNotificationAction(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int count = 0;
        if (state is NotificationLoaded) count = state.notifications.where((n) => !n.isRead).length;
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildCircleAction(Icons.notifications, Colors.black, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
            }),
            if (count > 0)
              Positioned(right: 8, top: 8, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text('$count', style: const TextStyle(fontSize: 10, color: Colors.white)))),
          ],
        );
      },
    );
  }

  Widget _buildCircleAction(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(icon: Icon(icon, color: color), onPressed: onTap);
  }

  Widget _buildStatusHeader(BuildContext context, String userName) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _showCreatePostSheet(context, userName),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(20)),
                child: Text("Bạn đang nghiên cứu gì thế, $userName?"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostList() {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostLoading) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        if (state is PostLoaded) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => PostCard(post: state.posts[index]),
              childCount: state.posts.length,
            ),
          );
        }
        return const SliverFillRemaining(child: Center(child: Text("Lỗi tải dữ liệu")));
      },
    );
  }
}