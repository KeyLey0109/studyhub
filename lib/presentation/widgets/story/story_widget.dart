import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/story_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/story/story_bloc.dart';
import '../common/avatar_widget.dart';

class StoryWidget extends StatelessWidget {
  const StoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, state) {
          final auth = context.read<AuthBloc>().state;
          final currentUser = auth is AuthAuthenticated ? auth.user : null;

          if (state is StoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<StoryEntity> stories = [];
          if (state is StoryLoaded) {
            stories = state.stories;
          }

          // Nếu có lỗi (ví dụ chưa có bảng), ta vẫn cho hiện danh sách trống để hiện nút "Tạo tin"
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: stories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCreateStoryCard(context, currentUser);
              }
              final story = stories[index - 1];
              return _buildStoryCard(context, story);
            },
          );
        },
      ),
    );
  }

  Widget _buildCreateStoryCard(BuildContext context, dynamic user) {
    return GestureDetector(
      onTap: () => context.push('/create-story'),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  image: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(user.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey.shade200,
                ),
                child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                    ? const Center(child: Icon(Icons.person, size: 40, color: Colors.grey))
                    : null,
              ),
            ),
            Expanded(
              flex: 1,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -15,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFF1877F2),
                        child: Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text(
                      'Tạo tin',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, StoryEntity story) {
    return GestureDetector(
      onTap: () => context.push('/story-view', extra: story),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: story.url != null
              ? DecorationImage(
                  image: NetworkImage(story.url!),
                  fit: BoxFit.cover,
                )
              : null,
          color: story.backgroundColor != null
              ? Color(int.parse(story.backgroundColor!.replaceFirst('#', '0xFF')))
              : Colors.blueAccent,
        ),
        child: Stack(
          children: [
            if (story.content != null && story.type == StoryType.text)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    story.content!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1877F2), width: 2),
                ),
                child: AvatarWidget(
                  name: story.userName,
                  imageUrl: story.userAvatar,
                  radius: 16,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                story.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
