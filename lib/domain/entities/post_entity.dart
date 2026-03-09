import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String? content;
  final List<String> mediaUrls;
  final List<String> mediaTypes; // 'image' or 'video' per item
  final List<String> likedByIds;
  final List<CommentEntity> comments;
  final DateTime createdAt;
  final bool isPublic;
  final PostEntity? sharedPost;

  const PostEntity({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.content,
    this.mediaUrls = const [],
    this.mediaTypes = const [],
    this.likedByIds = const [],
    this.comments = const [],
    required this.createdAt,
    this.isPublic = true,
    this.sharedPost,
  });

  int get likeCount => likedByIds.length;
  int get commentCount => comments.length;

  bool isLikedBy(String userId) => likedByIds.contains(userId);

  PostEntity copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? content,
    List<String>? mediaUrls,
    List<String>? mediaTypes,
    List<String>? likedByIds,
    List<CommentEntity>? comments,
    DateTime? createdAt,
    bool? isPublic,
    PostEntity? sharedPost,
  }) =>
      PostEntity(
        id: id ?? this.id,
        authorId: authorId ?? this.authorId,
        authorName: authorName ?? this.authorName,
        authorAvatar: authorAvatar ?? this.authorAvatar,
        content: content ?? this.content,
        mediaUrls: mediaUrls ?? this.mediaUrls,
        mediaTypes: mediaTypes ?? this.mediaTypes,
        likedByIds: likedByIds ?? this.likedByIds,
        comments: comments ?? this.comments,
        createdAt: createdAt ?? this.createdAt,
        isPublic: isPublic ?? this.isPublic,
        sharedPost: sharedPost ?? this.sharedPost,
      );

  @override
  List<Object?> get props => [
        id,
        authorId,
        content,
        mediaUrls,
        likedByIds,
        comments,
        createdAt,
        sharedPost
      ];
}

class CommentEntity extends Equatable {
  final String id;
  final String postId;
  final String? parentId; // null = top-level, set = reply
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final List<String> likedByIds;
  final List<CommentEntity> replies;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    this.parentId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.likedByIds = const [],
    this.replies = const [],
    required this.createdAt,
  });

  bool isLikedBy(String userId) => likedByIds.contains(userId);
  int get likeCount => likedByIds.length;

  CommentEntity copyWith(
          {List<String>? likedByIds, List<CommentEntity>? replies}) =>
      CommentEntity(
        id: id,
        postId: postId,
        parentId: parentId,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        content: content,
        likedByIds: likedByIds ?? this.likedByIds,
        replies: replies ?? this.replies,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props =>
      [id, postId, parentId, authorId, content, likedByIds, replies, createdAt];
}
