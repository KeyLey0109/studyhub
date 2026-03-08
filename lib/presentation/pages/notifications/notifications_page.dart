import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/friend/friend_bloc.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/notification_entity.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context
            .read<NotificationBloc>()
            .add(LoadNotificationsEvent(authState.user.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Thông báo',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.white,
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotifInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotifLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Chưa có thông báo nào',
                          style: TextStyle(color: AppTheme.textGrey)),
                    ]),
              );
            }
            return ListView.separated(
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, i) {
                final notif = state.notifications[i];
                return _NotifItem(
                    notif: notif,
                    onTap: () {
                      context
                          .read<NotificationBloc>()
                          .add(MarkReadEvent(notif.id));
                      if (notif.type == NotificationType.friendRequest) {
                        // Reload friend requests
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthAuthenticated) {
                          context
                              .read<FriendBloc>()
                              .add(LoadFriendsEvent(authState.user.id));
                        }
                        context.go('/friends');
                      } else if (notif.postId != null) {
                        context.push('/post/${notif.postId}');
                      }
                    });
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  final NotificationEntity notif;
  final VoidCallback onTap;
  const _NotifItem({required this.notif, required this.onTap});

  IconData get _icon {
    switch (notif.type) {
      case NotificationType.friendRequest:
        return Icons.person_add;
      case NotificationType.friendAccepted:
        return Icons.people;
      case NotificationType.postLike:
        return Icons.thumb_up;
      case NotificationType.postComment:
        return Icons.comment;
    }
  }

  Color get _iconColor {
    switch (notif.type) {
      case NotificationType.friendRequest:
        return AppTheme.primaryBlue;
      case NotificationType.friendAccepted:
        return Colors.green;
      case NotificationType.postLike:
        return AppTheme.primaryBlue;
      case NotificationType.postComment:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notif.isRead
            ? AppTheme.white
            : AppTheme.primaryBlue.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Stack(children: [
              AvatarWidget(
                  name: notif.fromUserName,
                  imageUrl: notif.fromUserAvatar,
                  radius: 24),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration:
                      BoxDecoration(color: _iconColor, shape: BoxShape.circle),
                  child: Icon(_icon, size: 10, color: Colors.white),
                ),
              ),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                      text: TextSpan(
                    style:
                        const TextStyle(color: AppTheme.textDark, fontSize: 14),
                    children: [
                      TextSpan(
                          text: notif.fromUserName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              ' ${notif.message.replaceFirst(notif.fromUserName, '').trim()}'),
                    ],
                  )),
                  const SizedBox(height: 2),
                  Text(
                    timeago.format(notif.createdAt, locale: 'vi'),
                    style: TextStyle(
                      fontSize: 12,
                      color: notif.isRead
                          ? AppTheme.textGrey
                          : AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            if (!notif.isRead)
              const CircleAvatar(
                  radius: 5, backgroundColor: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }
}
