import 'package:equatable/equatable.dart';
// 1. Import CommentEntity từ feature comment mới tạo
import '../../../comment/domain/entities/comment_entity.dart';

class PostEntity extends Equatable {
  final String id;
  final String userName;
  final String content;
  final String? imagePath;
  final String? videoPath;
  final DateTime timestamp; // Chuyển sang DateTime để dễ định dạng ngày tháng

  // 2. Danh sách các UserId đã Like bài viết này
  final List<String> likedByUsers;

  // 3. QUAN TRỌNG: Đổi từ List<String> sang List<CommentEntity>
  final List<CommentEntity> comments;

  const PostEntity({
    required this.id,
    required this.userName,
    required this.content,
    this.imagePath,
    this.videoPath,
    required this.timestamp,
    this.likedByUsers = const [],
    this.comments = const [],
  });

  // Getter tính tổng số Like
  int get likeCount => likedByUsers.length;

  // Kiểm tra xem sinh viên hiện tại đã Like chưa
  bool isLikedBy(String userId) => likedByUsers.contains(userId);

  // Hàm tạo bản sao để BLoC cập nhật trạng thái mới
  PostEntity copyWith({
    String? id,
    String? userName,
    String? content,
    String? imagePath,
    String? videoPath,
    DateTime? timestamp,
    List<String>? likedByUsers,
    List<CommentEntity>? comments, // Cập nhật kiểu dữ liệu ở đây
  }) {
    return PostEntity(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      videoPath: videoPath ?? this.videoPath,
      timestamp: timestamp ?? this.timestamp,
      likedByUsers: likedByUsers ?? this.likedByUsers,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userName,
    content,
    imagePath,
    videoPath,
    timestamp,
    likedByUsers,
    comments,
  ];
}