import 'package:equatable/equatable.dart';
import '../../../comment/domain/entities/comment_entity.dart';

/// [PostEntity] đại diện cho dữ liệu bài viết tại tầng Domain.
/// Tách biệt logic nghiệp vụ khỏi các chi tiết thực thi ở tầng Data.
class PostEntity extends Equatable {
  final String id;
  final String userName;
  final String content;
  final String? imagePath;
  final String? videoPath;
  final DateTime timestamp;
  final List<String> likedByUsers;
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

  // --- GETTERS TIỆN ÍCH ---

  int get likeCount => likedByUsers.length;
  int get commentCount => comments.length;
  bool isLikedBy(String userId) => likedByUsers.contains(userId);
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  bool get hasVideo => videoPath != null && videoPath!.isNotEmpty;

  // --- PHƯƠNG THỨC SAO CHÉP ---

  PostEntity copyWith({
    String? id,
    String? userName,
    String? content,
    String? imagePath,
    String? videoPath,
    DateTime? timestamp,
    List<String>? likedByUsers,
    List<CommentEntity>? comments,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      videoPath: videoPath ?? this.videoPath,
      timestamp: timestamp ?? this.timestamp,
      // Sử dụng List.from để ép buộc tạo vùng nhớ mới, giúp Bloc nhận diện thay đổi
      likedByUsers: likedByUsers ?? List<String>.from(this.likedByUsers),
      comments: comments ?? List<CommentEntity>.from(this.comments),
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