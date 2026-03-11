import 'package:equatable/equatable.dart';

enum NotificationType {
  friendRequest,
  friendAccepted,
  postLike,
  postComment,
}

class NotificationEntity extends Equatable {
  final String id;
  final String toUserId;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserAvatar;
  final NotificationType type;
  final String? postId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.toUserId,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserAvatar,
    required this.type,
    this.postId,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      toUserId: toUserId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserAvatar: fromUserAvatar,
      type: type,
      postId: postId,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, toUserId, fromUserId, type, postId, isRead, createdAt];
}
