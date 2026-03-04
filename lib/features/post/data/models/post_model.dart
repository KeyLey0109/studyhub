import '../../domain/entities/post_entity.dart';
import '../../../comment/data/models/comment_model.dart';
import '../../../comment/domain/entities/comment_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userName,
    required super.content,
    super.imagePath,
    super.videoPath,
    required super.timestamp,
    super.likedByUsers,
    super.comments,
  });

  // Chuyển đổi từ JSON (đọc từ SharedPreferences) sang Model
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userName: json['userName'] as String,
      content: json['content'] as String,
      imagePath: json['imagePath'] as String?,
      videoPath: json['videoPath'] as String?,
      // Chuyển đổi chuỗi ISO sang DateTime
      timestamp: DateTime.parse(json['timestamp'] as String),

      likedByUsers: List<String>.from(json['likedByUsers'] ?? []),

      // QUAN TRỌNG: Biến đổi từng phần tử JSON thành CommentModel (đệ quy)
      comments: (json['comments'] as List? ?? [])
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Chuyển đổi từ Model sang JSON để lưu xuống máy
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'content': content,
      'imagePath': imagePath,
      'videoPath': videoPath,
      'timestamp': timestamp.toIso8601String(), // Lưu dạng chuỗi để dễ đọc lại
      'likedByUsers': likedByUsers,

      // Biến đổi danh sách CommentEntity thành JSON
      'comments': comments.map((e) => (e as CommentModel).toJson()).toList(),
    };
  }

  // Chuyển đổi từ Entity (Tầng Domain) sang Model (Tầng Data)
  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      userName: entity.userName,
      content: entity.content,
      imagePath: entity.imagePath,
      videoPath: entity.videoPath,
      timestamp: entity.timestamp,
      likedByUsers: entity.likedByUsers,
      comments: entity.comments,
    );
  }
}