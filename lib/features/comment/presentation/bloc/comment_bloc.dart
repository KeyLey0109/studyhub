import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final AddCommentUseCase addCommentUseCase;
  final AuthBloc authBloc;

  CommentBloc({
    required this.addCommentUseCase,
    required this.authBloc,
  }) : super(CommentInitial()) {

    on<SubmitComment>((event, emit) async {
      // 1. Kiểm tra quyền truy cập từ AuthBloc
      final authState = authBloc.state;
      if (authState is! AuthSuccess) {
        emit(const CommentError("Vui lòng đăng nhập để thực hiện chức năng này"));
        return;
      }

      // 2. Trạng thái đang xử lý
      emit(CommentLoading());

      // 3. Gọi UseCase với thông tin người dùng hiện tại
      final result = await addCommentUseCase(
        postId: event.postId,
        content: event.content,
        userId: authState.user.id,
        userName: authState.user.name,
        parentCommentId: event.parentCommentId,
      );

      // 4. Trả về kết quả cuối cùng cho UI
      result.fold(
            (failure) => emit(CommentError(failure)),
            (_) {
          // Gửi thêm thông tin để UI biết đây là bình luận mới hay phản hồi
          emit(CommentSuccess());

          // Sau khi thành công, đưa về Initial để sẵn sàng cho bình luận tiếp theo
          emit(CommentInitial());
        },
      );
    });
  }
}