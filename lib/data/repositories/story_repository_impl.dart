import '../../domain/entities/story_entity.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasources/remote/supabase_remote_datasource.dart';
import '../datasources/local/hive_local_datasource.dart';

class StoryRepositoryImpl implements StoryRepository {
  final SupabaseRemoteDatasource remote;
  final HiveLocalDatasource local;

  StoryRepositoryImpl({required this.remote, required this.local});

  @override
  Future<List<StoryEntity>> getStories() async {
    return await remote.getStories();
  }

  @override
  Future<void> createStory(StoryEntity story) async {
    await remote.createStory(story);
  }

  @override
  Future<void> reactToStory(String storyId, StoryReaction reaction) async {
    await remote.reactToStory(storyId, reaction);
  }

  @override
  Future<void> deleteStory(String storyId) async {
    await remote.deleteStory(storyId);
  }
}
