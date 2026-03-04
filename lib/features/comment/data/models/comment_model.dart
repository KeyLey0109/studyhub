import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  // Constructor const giúp tối ưu hiệu năng render danh sách bình luận
  const CommentModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.content,
    required super.timestamp,
    required super.replies, // Truyền trực tiếp vào lớp cha thông qua super parameter
  });

  // Chuyển đổi từ Entity sang Model chuẩn đệ quy
  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      content: entity.content,
      timestamp: entity.timestamp,
      // Đệ quy chuyển đổi toàn bộ cây replies sang Model để đồng nhất kiểu dữ liệu
      replies: entity.replies.map((e) => CommentModel.fromEntity(e)).toList(),
    );
  }

  // Chuyển đổi từ JSON (SharedPreferences) sang Model
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      // Đệ quy nạp các reply con từ JSON
      replies: (json['replies'] as List? ?? [])
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Chuyển đổi từ Model sang JSON để lưu vào máy
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      // Điểm mấu chốt: Luôn đảm bảo đối tượng là Model trước khi gọi toJson
      'replies': replies.map((e) {
        final model = e is CommentModel ? e : CommentModel.fromEntity(e);
        return model.toJson();
      }).toList(),
    };
  }
}