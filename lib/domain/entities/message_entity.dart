import 'package:equatable/equatable.dart';

enum MessageType { text, image, video }

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final MessageType type;
  final String? mediaUrl;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.type = MessageType.text,
    this.mediaUrl,
  });

  @override
  List<Object?> get props => [id, senderId, receiverId, content, type, mediaUrl];
}
