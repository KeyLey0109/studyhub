import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;
  // Danh sách các phản hồi (đệ quy)
  final List<CommentEntity> replies;

  const CommentEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
    this.replies = const [], // Mặc định là danh sách hằng số rỗng
  });

  // Phương thức tạo bản sao để cập nhật trạng thái
  CommentEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? content,
    DateTime? timestamp,
    List<CommentEntity>? replies,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      // Đảm bảo tạo ra một List mới hoàn toàn để Flutter nhận diện thay đổi
      replies: replies ?? this.replies,
    );
  }

  // Getter tiện ích cho UI của StudyHub
  bool isMyComment(String currentUserId) => userId == currentUserId;

  // Tính tổng số lượng phản hồi (bao gồm cả các tầng sâu hơn)
  int get totalRepliesCount {
    int count = replies.length;
    for (var reply in replies) {
      count += reply.totalRepliesCount;
    }
    return count;
  }

  @override
  // Equatable giúp so sánh sâu các tầng bình luận để tránh render thừa
  List<Object?> get props => [id, userId, userName, content, timestamp, replies];
}