import '../../entities/story_entity.dart';
import '../../repositories/story_repository.dart';

class ReactToStoryUseCase {
  final StoryRepository repository;
  ReactToStoryUseCase(this.repository);

  Future<void> call(String storyId, StoryReaction reaction) async {
    return await repository.reactToStory(storyId, reaction);
  }
}
