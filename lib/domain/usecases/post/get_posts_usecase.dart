import '../../entities/post_entity.dart';
import '../../repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository repository;
  GetPostsUseCase(this.repository);
  Future<List<PostEntity>> call({int page = 1}) =>
      repository.getPosts(page: page);
}

class CreatePostUseCase {
  final PostRepository repository;
  CreatePostUseCase(this.repository);
  Future<PostEntity> call({
    required String authorId,
    required String authorName,
    String? authorAvatar,
    String? content,
    List<String> mediaUrls = const [],
    String mediaType = 'none',
  }) =>
      repository.createPost(
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        content: content,
        mediaUrls: mediaUrls,
        mediaTypes: mediaType != 'none' ? [mediaType] : [],
      );
}

class LikePostUseCase {
  final PostRepository repository;
  LikePostUseCase(this.repository);
  Future<PostEntity> call(
          {required String postId,
          required String userId,
          required bool isLiked}) =>
      isLiked
          ? repository.reactToPost(postId, userId, null)
          : repository.reactToPost(postId, userId, ReactionType.like);
}

class CommentPostUseCase {
  final PostRepository repository;
  CommentPostUseCase(this.repository);
  Future<PostEntity> call({
    required String postId,
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required String content,
  }) =>
      repository.addComment(
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        content: content,
      );
}
