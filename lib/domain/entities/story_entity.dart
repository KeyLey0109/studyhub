import 'package:equatable/equatable.dart';

enum StoryType { text, image, video }

class StoryEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final StoryType type;
  final String? url;
  final String? content;
  final String? backgroundColor;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<StoryReaction> reactions;

  const StoryEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.type,
    this.url,
    this.content,
    this.backgroundColor,
    required this.createdAt,
    required this.expiresAt,
    this.reactions = const [],
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userAvatar,
        type,
        url,
        content,
        backgroundColor,
        createdAt,
        expiresAt,
        reactions,
      ];
}

class StoryReaction extends Equatable {
  final String userId;
  final String emoji;

  const StoryReaction({required this.userId, required this.emoji});

  @override
  List<Object?> get props => [userId, emoji];
}
