import '../entities/story_entity.dart';

abstract class StoryRepository {
  Future<List<StoryEntity>> getStories();
  Future<void> createStory(StoryEntity story);
  Future<void> reactToStory(String storyId, StoryReaction reaction);
  Future<void> deleteStory(String storyId);
}
