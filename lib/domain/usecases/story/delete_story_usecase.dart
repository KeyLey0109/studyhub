import '../../repositories/story_repository.dart';

class DeleteStoryUseCase {
  final StoryRepository repository;
  DeleteStoryUseCase(this.repository);

  Future<void> call(String storyId) async {
    return await repository.deleteStory(storyId);
  }
}
