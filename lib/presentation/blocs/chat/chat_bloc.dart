import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/datasources/local/hive_local_datasource.dart';
import '../../../../domain/entities/message_entity.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final HiveLocalDatasource localDatasource;
  final Uuid _uuid = const Uuid();

  ChatBloc({required this.localDatasource}) : super(ChatInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
  }

  void _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) {
    try {
      emit(ChatLoading());
      final messages = localDatasource.getMessagesBetween(
        event.currentUserId,
        event.otherUserId,
      );
      emit(ChatLoaded(messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      final newMessage = MessageEntity(
        id: _uuid.v4(),
        senderId: event.currentUserId,
        receiverId: event.otherUserId,
        content: event.content,
        createdAt: DateTime.now(),
      );

      await localDatasource.saveMessage(newMessage);

      if (state is ChatLoaded) {
        final currentMessages = (state as ChatLoaded).messages;
        emit(ChatLoaded([...currentMessages, newMessage]));
      } else {
        emit(ChatLoaded([newMessage]));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
