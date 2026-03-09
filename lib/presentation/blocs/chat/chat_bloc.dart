import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/datasources/local/hive_local_datasource.dart';
import '../../../../data/datasources/remote/supabase_remote_datasource.dart';
import '../../../../domain/entities/message_entity.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SupabaseRemoteDatasource remoteDatasource;
  final HiveLocalDatasource localDatasource;
  final Uuid _uuid = const Uuid();

  ChatBloc({
    required this.remoteDatasource,
    required this.localDatasource,
  }) : super(ChatInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onLoadMessages(
      LoadMessagesEvent event, Emitter<ChatState> emit) async {
    try {
      final isSilent = state is ChatLoaded;
      if (!isSilent) {
        emit(ChatLoading());
      }
      // Fast load from local
      final localMsgs = localDatasource.getMessagesBetween(
        event.currentUserId,
        event.otherUserId,
      );
      if (!isSilent || localMsgs.isNotEmpty) {
        emit(ChatLoaded(localMsgs));
      }

      // Fetch from Supabase
      try {
        final remoteMsgs = await remoteDatasource.getMessages(
            event.currentUserId, event.otherUserId);

        // Save to local cache
        for (final msg in remoteMsgs) {
          await localDatasource.saveMessage(msg);
        }

        if (!isClosed) emit(ChatLoaded(remoteMsgs));
      } catch (_) {
        // Silently fail network error, keep showing local
      }
    } catch (e) {
      if (state is! ChatLoaded) {
        emit(ChatError(e.toString()));
      }
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      // Optimistic update
      final optimisticMessage = MessageEntity(
        id: _uuid.v4(),
        senderId: event.currentUserId,
        receiverId: event.otherUserId,
        content: event.content,
        createdAt: DateTime.now(),
      );

      await localDatasource.saveMessage(optimisticMessage);

      if (state is ChatLoaded) {
        final currentMessages = (state as ChatLoaded).messages;
        emit(ChatLoaded([...currentMessages, optimisticMessage]));
      } else {
        emit(ChatLoaded([optimisticMessage]));
      }

      // Send to Supabase
      final savedRemote = await remoteDatasource.sendMessage(
          event.currentUserId, event.otherUserId, event.content);
      await localDatasource.saveMessage(savedRemote);

      // Replace optimistic with real one (to get the real ID and exact timestamp)
      if (state is ChatLoaded) {
        final currentMessages = (state as ChatLoaded).messages;
        final updatedMessages = currentMessages
            .map((m) => m.id == optimisticMessage.id ? savedRemote : m)
            .toList();
        emit(ChatLoaded(updatedMessages));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
