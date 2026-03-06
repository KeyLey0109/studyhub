import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_event.dart';
import 'post_state.dart';

<<<<<<< HEAD
// Domain Layer
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/get_post_usecase.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/toggle_like_usecase.dart';
import '../../../comment/domain/entities/comment_entity.dart';
import '../../../comment/domain/usecases/add_comment_usecase.dart';

// Data Layer
import '../../data/models/post_model.dart';
import '../../data/datasources/post_local_data_source.dart';
import '../../../comment/data/models/comment_model.dart';

// Auth Layer
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
=======
// Import Entities và UseCases từ tầng Domain
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/get_post_usecase.dart';
import '../../domain/usecases/create_post_usecase.dart';

// Import các dependencies từ các features khác
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../comment/domain/entities/comment_entity.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
>>>>>>> origin/feature

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPostsUseCase;
  final CreatePostUseCase createPostUseCase;
<<<<<<< HEAD
  final ToggleLikeUseCase toggleLikeUseCase;
  final AddCommentUseCase addCommentUseCase;
  final PostLocalDataSource localDataSource;
  final AuthBloc authBloc;
  String?
      _currentUserId; // Lưu trữ userId hiện tại để reload đúng Wall sau khi đăng bài
=======
  final AuthBloc authBloc;
  final NotificationBloc notificationBloc;
>>>>>>> origin/feature

  PostBloc({
    required this.getPostsUseCase,
    required this.createPostUseCase,
<<<<<<< HEAD
    required this.toggleLikeUseCase,
    required this.addCommentUseCase,
    required this.localDataSource,
    required this.authBloc,
  }) : super(PostInitial()) {
=======
    required this.authBloc,
    required this.notificationBloc,
  }) : super(PostInitial()) {
    // Đăng ký các sự kiện
>>>>>>> origin/feature
    on<LoadPosts>(_onLoadPosts);
    on<CreatePostRequested>(_onCreatePost);
    on<ToggleLike>(_onToggleLike);
    on<AddComment>(_onAddComment);
<<<<<<< HEAD
    on<DeletePost>(_onDeletePost);
  }

=======
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
  }

  /// Helper để lấy thông tin người dùng hiện tại từ AuthBloc
>>>>>>> origin/feature
  AuthSuccess? get _currentAuth {
    final authState = authBloc.state;
    return authState is AuthSuccess ? authState : null;
  }

<<<<<<< HEAD
  /// 1. Xử lý Load bài viết (Dứt điểm lỗi dòng 60)
  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    _currentUserId = event.userId;
    emit(PostLoading());

    final localPosts = await localDataSource.getLastPosts();
    if (localPosts.isNotEmpty) {
      emit(PostLoaded(posts: localPosts));
    }

    final result = await getPostsUseCase(userId: event.userId);
    result.fold(
      (failure) {
        if (localPosts.isEmpty) emit(PostError(message: failure.toString()));
      },
      (posts) {
        emit(PostLoaded(posts: posts));
        // CHỈ cache khi đây là lần tải toàn bộ (userId == null)
        // Nếu tải theo userId (Trang cá nhân), việc cache sẽ làm mất các bài viết khác!
        if (event.userId == null) {
          final models = posts.map((e) => PostModel.fromEntity(e)).toList();
          localDataSource.cachePosts(models);
        }
=======
  /// Xử lý tải danh sách bài viết
  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());
    final result = await getPostsUseCase();

    result.fold(
      (failure) => emit(PostError(message: failure.toString())),
      (posts) => emit(PostLoaded(posts: posts)),
    );
  }

  /// Xử lý tạo bài viết mới
  Future<void> _onCreatePost(
      CreatePostRequested event, Emitter<PostState> emit) async {
    final user = _currentAuth?.user;
    if (user == null) return;

    // Hiển thị trạng thái đang tạo trên UI (nếu đang ở màn hình danh sách)
    if (state is PostLoaded) {
      emit((state as PostLoaded).copyWith(isCreating: true));
    }

    final result = await createPostUseCase(
      content: event.content,
      image: event.image,
      video: event.video,
      userName: user.name,
    );

    result.fold(
      (failure) {
        if (state is PostLoaded) {
          emit((state as PostLoaded).copyWith(isCreating: false));
        }
        emit(PostError(message: failure.toString()));
      },
      (_) {
        add(const LoadPosts()); // Tải lại danh sách sau khi tạo thành công

        // Bắn thông báo ngay lập tức
        notificationBloc.add(NotificationReceived(NotificationEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'system',
          senderName: 'Hệ thống',
          message: 'Bạn vừa đăng một bài viết mới.',
          type: NotificationType.postMention,
          timestamp: DateTime.now(),
        )));
>>>>>>> origin/feature
      },
    );
  }

<<<<<<< HEAD
  /// 2. Xử lý Like (Dứt điểm lỗi dòng 93)
=======
  /// Xử lý Like/Unlike bài viết (Cập nhật tức thì trên UI)
>>>>>>> origin/feature
  Future<void> _onToggleLike(ToggleLike event, Emitter<PostState> emit) async {
    final currentState = state;
    final user = _currentAuth?.user;

    if (currentState is PostLoaded && user != null) {
      final String userId = user.id;

      final List<PostEntity> updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
<<<<<<< HEAD
          final List<String> newLikes = List<String>.from(post.likedByUsers);
          newLikes.contains(userId)
              ? newLikes.remove(userId)
              : newLikes.add(userId);
          return post.copyWith(likedByUsers: newLikes);
=======
          // Tạo bản sao mới của danh sách likes để kích hoạt Equatable
          final List<String> newLikedByUsers =
              List<String>.from(post.likedByUsers);

          if (newLikedByUsers.contains(userId)) {
            newLikedByUsers.remove(userId);
          } else {
            newLikedByUsers.add(userId);
          }

          return post.copyWith(likedByUsers: newLikedByUsers);
>>>>>>> origin/feature
        }
        return post;
      }).toList();

      emit(currentState.copyWith(posts: updatedPosts));

<<<<<<< HEAD
      // Gọi UseCase để xử lý đồng bộ tầng Repository và Local Cache
      await toggleLikeUseCase(event.postId, userId);
    }
  }

  /// 3. Xử lý Comment (Sửa lỗi mất Like bằng cách gọi UseCase chính thống)
=======
      // Chỗ này Việt có thể gọi thêm UseCase để lưu trạng thái Like vào Database/Local
    }
  }

  /// Xử lý thêm bình luận mới
>>>>>>> origin/feature
  Future<void> _onAddComment(AddComment event, Emitter<PostState> emit) async {
    final currentState = state;
    final user = _currentAuth?.user;

    if (currentState is PostLoaded && user != null) {
<<<<<<< HEAD
      // 1. Cập nhật UI ngay lập tức (Optimistic UI)
      final List<PostEntity> updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          final newComment = CommentModel(
            id: "cmt_${DateTime.now().millisecondsSinceEpoch}",
=======
      final List<PostEntity> updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          final newComment = CommentEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
>>>>>>> origin/feature
            userId: user.id,
            userName: user.name,
            content: event.commentContent,
            timestamp: DateTime.now(),
            replies: const [],
          );

<<<<<<< HEAD
=======
          // Cập nhật danh sách bình luận bằng cách tạo List mới
>>>>>>> origin/feature
          final List<CommentEntity> updatedComments =
              List<CommentEntity>.from(post.comments)..add(newComment);

          return post.copyWith(comments: updatedComments);
        }
        return post;
      }).toList();

      emit(currentState.copyWith(posts: updatedPosts));
<<<<<<< HEAD

      // 2. Gọi UseCase để Repository cập nhật Cache của chính nó và disk cache
      await addCommentUseCase(
        postId: event.postId,
        content: event.commentContent,
        userId: user.id,
        userName: user.name,
      );
    }
  }

  /// 4. Tạo bài viết
  Future<void> _onCreatePost(
      CreatePostRequested event, Emitter<PostState> emit) async {
    final user = _currentAuth?.user;
    if (user == null) return;

    final result = await createPostUseCase(
      content: event.content,
      userId: event.userId,
      imagePath: event.imagePath,
      videoPath: event.videoPath,
      userName: event.userName,
      userAvatarUrl: event.userAvatarUrl,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.toString())),
      (_) => add(LoadPosts(userId: _currentUserId)), // Reload đúng filter cũ
    );
  }

  /// 5. Xóa bài viết (Dứt điểm lỗi dòng 158)
  Future<void> _onDeletePost(DeletePost event, Emitter<PostState> emit) async {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final updatedPosts =
          currentState.posts.where((post) => post.id != event.postId).toList();

      emit(currentState.copyWith(posts: updatedPosts));

      final modelsToCache =
          updatedPosts.map((e) => PostModel.fromEntity(e)).toList();
      await localDataSource.cachePosts(modelsToCache);
=======
    }
  }

  /// Cập nhật một bài viết cụ thể
  void _onUpdatePost(UpdatePost event, Emitter<PostState> emit) {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final List<PostEntity> updatedPosts = currentState.posts.map((post) {
        return post.id == event.post.id ? event.post : post;
      }).toList();
      emit(currentState.copyWith(posts: updatedPosts));
    }
  }

  /// Xóa bài viết khỏi danh sách hiển thị
  void _onDeletePost(DeletePost event, Emitter<PostState> emit) {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final List<PostEntity> updatedPosts =
          currentState.posts.where((post) => post.id != event.postId).toList();
      emit(currentState.copyWith(posts: updatedPosts));
>>>>>>> origin/feature
    }
  }
}
