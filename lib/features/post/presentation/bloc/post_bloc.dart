import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_event.dart';
import 'post_state.dart';
import '../../domain/usecases/get_post_usecase.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/entities/post_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

// Import thêm để nhận diện CommentEntity
import '../../../comment/domain/entities/comment_entity.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final AuthBloc authBloc;

  PostBloc({
    required this.getPostsUseCase,
    required this.createPostUseCase,
    required this.authBloc,
  }) : super(PostInitial()) {

    // 1. Tải danh sách bài viết từ máy hoặc server
    on<LoadPosts>((event, emit) async {
      emit(PostLoading());
      final result = await getPostsUseCase();
      result.fold(
            (failure) => emit(PostError(message: failure)),
            (posts) => emit(PostLoaded(posts: posts)),
      );
    });

    // 2. Đăng bài mới (Lấy userName thật từ Event đã sửa)
    on<AddPost>((event, emit) async {
      final result = await createPostUseCase(
        content: event.content,
        image: event.image,
        video: event.video,
        userName: event.userName,
      );

      result.fold(
            (failure) => emit(PostError(message: failure)),
            (_) => add(const LoadPosts()),
      );
    });

    // 3. Xử lý Like/Unlike theo tài khoản (Sử dụng likedByUsers chuẩn Entity mới)
    on<ToggleLike>((event, emit) {
      if (state is PostLoaded) {
        final authState = authBloc.state;
        if (authState is! AuthSuccess) return;
        final String currentUserId = authState.user.id;

        final List<PostEntity> currentPosts = (state as PostLoaded).posts;

        final updatedPosts = currentPosts.map((post) {
          if (post.id == event.postId) {
            List<String> newLikedByUsers = List.from(post.likedByUsers);

            if (newLikedByUsers.contains(currentUserId)) {
              newLikedByUsers.remove(currentUserId);
            } else {
              newLikedByUsers.add(currentUserId);
            }
            return post.copyWith(likedByUsers: newLikedByUsers);
          }
          return post;
        }).toList();

        emit(PostLoaded(posts: updatedPosts));
      }
    });

    // 4. CẬP NHẬT QUAN TRỌNG: Thêm Bình luận chuẩn Entity mới
    on<AddComment>((event, emit) {
      if (state is PostLoaded) {
        final authState = authBloc.state;
        if (authState is! AuthSuccess) return;

        final List<PostEntity> currentPosts = (state as PostLoaded).posts;

        final updatedPosts = currentPosts.map((post) {
          if (post.id == event.postId) {
            // Tạo đối tượng CommentEntity mới thay vì String
            final newComment = CommentEntity(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: authState.user.id,
              userName: authState.user.name,
              content: event.commentContent,
              timestamp: DateTime.now(),
              replies: const [], // Mặc định bình luận mới chưa có phản hồi
            );

            // Cập nhật danh sách comments kiểu List<CommentEntity>
            final updatedComments = List<CommentEntity>.from(post.comments)..add(newComment);
            return post.copyWith(comments: updatedComments);
          }
          return post;
        }).toList();

        emit(PostLoaded(posts: updatedPosts));
      }
    });

    // 5. Cập nhật bài viết thủ công (Sửa lỗi copy bài viết)
    on<UpdatePost>((event, emit) {
      if (state is PostLoaded) {
        final List<PostEntity> updatedPosts = (state as PostLoaded).posts.map((post) {
          return post.id == event.post.id ? event.post : post;
        }).toList();
        emit(PostLoaded(posts: updatedPosts));
      }
    });

    // 6. Xóa bài viết
    on<DeletePost>((event, emit) {
      if (state is PostLoaded) {
        final updatedPosts = (state as PostLoaded).posts
            .where((post) => post.id != event.postId)
            .toList();
        emit(PostLoaded(posts: updatedPosts));
      }
    });
  }
}