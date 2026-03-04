import 'package:equatable/equatable.dart';
import '../../domain/entities/post_entity.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu khi chưa có dữ liệu
class PostInitial extends PostState {}

/// Trạng thái đang tải dữ liệu (hiển thị CircularProgressIndicator)
class PostLoading extends PostState {}

/// Trạng thái đã tải dữ liệu thành công
/// Đây là phần giúp sửa lỗi "PostLoaded isn't defined"
class PostLoaded extends PostState {
  final List<PostEntity> posts;

  const PostLoaded({required this.posts});

  @override
  List<Object?> get props => [posts];
}

/// Trạng thái xảy ra lỗi
/// Đây là phần giúp sửa lỗi "PostError isn't defined"
class PostError extends PostState {
  final String message;

  const PostError({required this.message});

  @override
  List<Object?> get props => [message];
}