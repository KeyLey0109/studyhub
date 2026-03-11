import '../entities/user_entity.dart';
import '../entities/notification_entity.dart';

abstract class FriendRepository {
  Future<void> sendFriendRequest({required String fromId, required String toId});
  Future<void> acceptFriendRequest({required String fromId, required String toId});
  Future<void> declineFriendRequest({required String fromId, required String toId});
  Future<List<UserEntity>> getFriendRequests(String userId);
  Future<List<UserEntity>> getFriends(String userId);
  Future<List<UserEntity>> getSuggestions(String userId);
  Future<List<NotificationEntity>> getNotifications(String userId);
  Future<void> markNotificationRead(String notificationId);
}
