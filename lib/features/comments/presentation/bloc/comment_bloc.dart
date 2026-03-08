import 'package:flutter_bloc/flutter_bloc.dart';
import 'comment_event.dart';
import 'comment_state.dart';
import '../../domain/entities/comment_entity.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc() : super(CommentInitial()) {
    on<LoadComments>((event, emit) async {
      emit(CommentLoading());
      try {
        // Giả lập lấy dữ liệu bình luận
        await Future.delayed(const Duration(milliseconds: 500));
        final mockComments = [
          CommentEntity(
              id: '1',
              postId: event.postId,
              userName: 'Việt',
              content: 'Bài viết rất hay!',
              createdAt: DateTime.now()
          ),
        ];
        emit(CommentLoaded(mockComments));
      } catch (e) {
        emit(CommentError("Không thể tải bình luận"));
      }
    });

    on<AddComment>((event, emit) {
      if (state is CommentLoaded) {
        final currentComments = (state as CommentLoaded).comments;
        final newComment = CommentEntity(
          id: DateTime.now().toString(),
          postId: event.postId,
          userName: 'Me',
          content: event.content,
          createdAt: DateTime.now(),
        );
        emit(CommentLoaded([...currentComments, newComment]));
      }
    });
  }
}