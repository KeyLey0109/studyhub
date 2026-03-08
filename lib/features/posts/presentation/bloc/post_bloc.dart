import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/post_repository.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository repository;

  // Sửa lỗi: Khởi tạo với PostInitial() thay vì PostState()
  PostBloc(this.repository) : super(PostInitial()) {
    on<LoadPostsEvent>(_load);
    on<CreatePostEvent>(_create);
    on<LikePostEvent>(_like);
  }

  Future<void> _load(LoadPostsEvent event, Emitter<PostState> emit) async {
    // 1. Phát ra trạng thái đang tải
    emit(PostLoading());
    try {
      final posts = await repository.getPosts(1);
      // 2. Trả về PostLoaded kèm danh sách posts
      emit(PostLoaded(posts: List.from(posts)));
    } catch (e) {
      // 3. Trả về lỗi nếu có
      emit(PostError("Không thể tải bài viết: ${e.toString()}"));
    }
  }

  Future<void> _create(CreatePostEvent event, Emitter<PostState> emit) async {
    try {
      await repository.createPost(
        event.content,
        imagePath: event.imagePath,
        videoPath: event.videoPath,
      );

      final posts = await repository.getPosts(1);
      emit(PostLoaded(posts: List.from(posts)));
    } catch (e) {
      emit(PostError("Lỗi khi tạo bài viết"));
    }
  }

  Future<void> _like(LikePostEvent event, Emitter<PostState> emit) async {
    try {
      await repository.likePost(event.id);

      final posts = await repository.getPosts(1);
      // Giữ giao diện đồng bộ bằng cách phát lại PostLoaded
      emit(PostLoaded(posts: List.from(posts)));
    } catch (e) {
      // Có thể giữ nguyên state cũ nếu like lỗi
    }
  }
}