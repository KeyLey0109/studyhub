import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../data/datasources/local/hive_local_datasource.dart';
import '../../../data/datasources/remote/supabase_remote_datasource.dart';
import '../../../injection_container.dart' as di;

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {
  final String userId;
  LoadNotificationsEvent(this.userId);
}

class MarkReadEvent extends NotificationEvent {
  final String id;
  MarkReadEvent(this.id);
}

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotifInitial extends NotificationState {}

class NotifLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  NotifLoaded(this.notifications);
  int get unreadCount => notifications.where((n) => !n.isRead).length;
  @override
  List<Object?> get props => [notifications];
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final HiveLocalDatasource local;
  NotificationBloc({required this.local}) : super(NotifInitial()) {
    on<LoadNotificationsEvent>((event, emit) async {
      // Fast emit local
      final localNotifs = local.getNotificationsForUser(event.userId);
      emit(NotifLoaded(localNotifs));

      try {
        final remote = di.sl<SupabaseRemoteDatasource>();
        final freshNotifs = await remote.getNotifications(event.userId);
        for (var n in freshNotifs) {
          await local.saveNotification(n);
        }
        if (!isClosed) emit(NotifLoaded(freshNotifs));
      } catch (e) {
        // Fallback to local on error
      }
    });

    on<MarkReadEvent>((event, emit) async {
      await local.markNotifRead(event.id);

      try {
        final remote = di.sl<SupabaseRemoteDatasource>();
        await remote.markNotificationRead(event.id);
      } catch (_) {}

      if (state is NotifLoaded) {
        final notifs = (state as NotifLoaded)
            .notifications
            .map((n) => n.id == event.id ? n.copyWith(isRead: true) : n)
            .toList();
        emit(NotifLoaded(notifs));
      }
    });
  }
}
