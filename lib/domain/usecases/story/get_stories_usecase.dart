import '../../entities/story_entity.dart';
import '../../repositories/story_repository.dart';

class GetStoriesUseCase {
  final StoryRepository repository;
  GetStoriesUseCase(this.repository);

  Future<List<StoryEntity>> call() async {
    return await repository.getStories();
  }
}
