import '../../entities/user_entity.dart';
import '../../repositories/friend_repository.dart';

class SendFriendRequestUseCase {
  final FriendRepository repository;
  SendFriendRequestUseCase(this.repository);
  Future<void> call({required String fromId, required String toId}) =>
      repository.sendFriendRequest(fromId: fromId, toId: toId);
}

class AcceptFriendRequestUseCase {
  final FriendRepository repository;
  AcceptFriendRequestUseCase(this.repository);
  Future<void> call({required String fromId, required String toId, required bool accept}) =>
      accept
          ? repository.acceptFriendRequest(fromId: fromId, toId: toId)
          : repository.declineFriendRequest(fromId: fromId, toId: toId);
}

class GetFriendRequestsUseCase {
  final FriendRepository repository;
  GetFriendRequestsUseCase(this.repository);
  Future<List<UserEntity>> call(String userId) => repository.getFriendRequests(userId);
}

class GetFriendsUseCase {
  final FriendRepository repository;
  GetFriendsUseCase(this.repository);
  Future<List<UserEntity>> call(String userId) => repository.getFriends(userId);
}

class GetSuggestionsUseCase {
  final FriendRepository repository;
  GetSuggestionsUseCase(this.repository);
  Future<List<UserEntity>> call(String userId) => repository.getSuggestions(userId);
}
