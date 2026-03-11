import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? coverUrl;
  final String? bio;
  final String? location;
  final List<String> friendIds;
  final List<String> pendingRequestIds; // requests received
  final List<String> sentRequestIds;   // requests sent
  final DateTime createdAt;
  final String? password; // Thêm trường password để database giả lập hoạt động

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.coverUrl,
    this.bio,
    this.location,
    this.friendIds = const [],
    this.pendingRequestIds = const [],
    this.sentRequestIds = const [],
    required this.createdAt,
    this.password,
  });

  bool isFriendWith(String userId) => friendIds.contains(userId);
  bool hasPendingRequestFrom(String userId) => pendingRequestIds.contains(userId);
  bool hasSentRequestTo(String userId) => sentRequestIds.contains(userId);

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? coverUrl,
    String? bio,
    String? location,
    List<String>? friendIds,
    List<String>? pendingRequestIds,
    List<String>? sentRequestIds,
    DateTime? createdAt,
    String? password,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      friendIds: friendIds ?? this.friendIds,
      pendingRequestIds: pendingRequestIds ?? this.pendingRequestIds,
      sentRequestIds: sentRequestIds ?? this.sentRequestIds,
      createdAt: createdAt ?? this.createdAt,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [
    id, name, email, phone, avatarUrl, coverUrl,
    bio, location, friendIds, pendingRequestIds, sentRequestIds, createdAt, password
  ];
}
