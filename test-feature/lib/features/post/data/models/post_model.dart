import 'package:appstudyhub/features/post/domain/entities/post_entity.dart';
import 'package:appstudyhub/features/comment/data/models/comment_model.dart';
// Import này cực kỳ quan trọng để định nghĩa kiểu dữ liệu trong hàm map, giúp hết lỗi Unused
import 'package:appstudyhub/features/comment/domain/entities/comment_entity.dart';

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

  /// Chuyển đổi từ JSON (Map) sang PostModel
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Người dùng',
      content: json['content'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      videoPath: json['videoPath'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      likedByUsers: List<String>.from(json['likedByUsers'] ?? []),
      // Ép kiểu danh sách comments sang CommentModel ngay từ khi load dữ liệu
      comments: (json['comments'] as List? ?? [])
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Chuyển đổi PostModel sang JSON (Map) để lưu vào SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'content': content,
      'imagePath': imagePath,
      'videoPath': videoPath,
      'timestamp': timestamp.toIso8601String(),
      'likedByUsers': likedByUsers,
      // Sử dụng CommentEntity e để giữ import hợp lệ và xóa lỗi Unused
      'comments': comments.map((CommentEntity e) {
        if (e is CommentModel) return e.toJson();
        return CommentModel.fromEntity(e).toJson();
      }).toList(),
    };
  }

  /// Chuyển đổi từ PostEntity sang PostModel (Dùng trong Repository/Bloc)
  /// Đây là hàm quan trọng nhất để dứt điểm lỗi "subtype" màn hình đỏ
  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      userName: entity.userName,
      content: entity.content,
      imagePath: entity.imagePath,
      videoPath: entity.videoPath,
      timestamp: entity.timestamp,
      likedByUsers: entity.likedByUsers,
      // Duyệt danh sách và đảm bảo mọi phần tử đều là Model trước khi trả về
      comments: entity.comments.map<CommentModel>((CommentEntity e) {
        if (e is CommentModel) return e;
        return CommentModel.fromEntity(e);
      }).toList(),
    );
  }
}