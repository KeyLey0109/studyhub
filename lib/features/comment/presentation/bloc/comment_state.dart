import 'package:equatable/equatable.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

/// Khi gửi thành công, UI sẽ tự động xóa chữ trong TextField
class CommentSuccess extends CommentState {}

class CommentError extends CommentState {
  final String message;
  const CommentError(this.message);

  @override
  List<Object?> get props => [message];
}