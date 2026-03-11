import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/story_entity.dart';
import '../../../domain/usecases/story/get_stories_usecase.dart';
import '../../../domain/usecases/story/create_story_usecase.dart';
import '../../../domain/usecases/story/react_to_story_usecase.dart';
import '../../../domain/usecases/story/delete_story_usecase.dart';

abstract class StoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStoriesEvent extends StoryEvent {}

class CreateStoryEvent extends StoryEvent {
  final StoryEntity story;
  CreateStoryEvent(this.story);
  @override
  List<Object?> get props => [story];
}

class ReactToStoryEvent extends StoryEvent {
  final String storyId;
  final StoryReaction reaction;
  ReactToStoryEvent(this.storyId, this.reaction);
  @override
  List<Object?> get props => [storyId, reaction];
}

class DeleteStoryEvent extends StoryEvent {
  final String storyId;
  DeleteStoryEvent(this.storyId);
  @override
  List<Object?> get props => [storyId];
}

abstract class StoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StoryLoaded extends StoryState {
  final List<StoryEntity> stories;
  StoryLoaded(this.stories);
  @override
  List<Object?> get props => [stories];
}

class StoryError extends StoryState {
  final String message;
  StoryError(this.message);
  @override
  List<Object?> get props => [message];
}

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  final GetStoriesUseCase getStoriesUseCase;
  final CreateStoryUseCase createStoryUseCase;
  final ReactToStoryUseCase reactToStoryUseCase;
  final DeleteStoryUseCase deleteStoryUseCase;

  StoryBloc({
    required this.getStoriesUseCase,
    required this.createStoryUseCase,
    required this.reactToStoryUseCase,
    required this.deleteStoryUseCase,
  }) : super(StoryInitial()) {
    on<LoadStoriesEvent>((event, emit) async {
      emit(StoryLoading());
      try {
        final stories = await getStoriesUseCase();
        emit(StoryLoaded(stories));
      } catch (e) {
        emit(StoryError(e.toString()));
      }
    });

    on<CreateStoryEvent>((event, emit) async {
      try {
        await createStoryUseCase(event.story);
        add(LoadStoriesEvent());
      } catch (e) {
        emit(StoryError(e.toString()));
      }
    });

    on<ReactToStoryEvent>((event, emit) async {
      try {
        await reactToStoryUseCase(event.storyId, event.reaction);
      } catch (e) {}
    });

    on<DeleteStoryEvent>((event, emit) async {
      try {
        await deleteStoryUseCase(event.storyId);
        add(LoadStoriesEvent());
      } catch (e) {
        emit(StoryError(e.toString()));
      }
    });
  }
}
