import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_event.dart';
import 'post_state.dart';
import '../../domain/usecases/get_post_usecase.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/entities/post_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

// Import để nhận diện CommentEntity
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

    // 1. Tải danh sách bài viết
    on<LoadPosts>((event, emit) async {
      emit(PostLoading());
      final result = await getPostsUseCase();
      result.fold(
            (failure) => emit(PostError(message: failure)),
            (posts) => emit(PostLoaded(posts: posts)),
      );
    });

    // 2. Xử lý đăng bài: Tận dụng trạng thái isCreating đã thêm ở PostState
    on<CreatePostRequested>((event, emit) async {
      final currentState = state;
      if (currentState is PostLoaded) {
        emit(currentState.copyWith(isCreating: true)); // Hiện thanh loading nhỏ
      }

      final result = await createPostUseCase(
        content: event.content,
        image: event.image,
        video: event.video,
        userName: event.userName ?? "Sinh viên",
      );

      result.fold(
            (failure) {
          if (state is PostLoaded) {
            emit((state as PostLoaded).copyWith(isCreating: false));
          }
          emit(PostError(message: failure));
        },
            (_) => add(const LoadPosts()),
      );
    });

    // 3. Xử lý Like/Unlike: Kiểm tra kỹ trạng thái đăng nhập
    on<ToggleLike>((event, emit) {
      final authState = authBloc.state;
      if (authState is AuthSuccess && state is PostLoaded) {
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
      } else if (authState is! AuthSuccess) {
        // Nếu chưa đăng nhập thành công, phát lỗi cảnh báo
        emit(const PostError(message: "Bạn cần đăng nhập để thực hiện chức năng này!"));
      }
    });

    // 4. Xử lý Bình luận: Lấy User trực tiếp từ AuthBloc để tránh lỗi "nhầm" trạng thái
    on<AddComment>((event, emit) {
      final authState = authBloc.state;
      final currentState = state;

      if (authState is AuthSuccess && currentState is PostLoaded) {
        final List<PostEntity> currentPosts = currentState.posts;

        final updatedPosts = currentPosts.map((post) {
          if (post.id == event.postId) {
            final newComment = CommentEntity(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: authState.user.id,
              userName: authState.user.name,
              content: event.commentContent,
              timestamp: DateTime.now(),
              replies: const [],
            );

            final updatedComments = List<CommentEntity>.from(post.comments)..add(newComment);
            return post.copyWith(comments: updatedComments);
          }
          return post;
        }).toList();

        emit(PostLoaded(posts: updatedPosts));
      } else if (authState is! AuthSuccess) {
        // Fix lỗi: Báo lỗi cụ thể khi AuthBloc không ở trạng thái thành công
        emit(const PostError(message: "Phiên đăng nhập hết hạn, vui lòng kiểm tra lại!"));
      }
    });

    // 5. Cập nhật bài viết thủ công
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