import '../../entities/story_entity.dart';
import '../../repositories/story_repository.dart';

class CreateStoryUseCase {
  final StoryRepository repository;
  CreateStoryUseCase(this.repository);

  Future<void> call(StoryEntity story) async {
    return await repository.createStory(story);
  }
}
