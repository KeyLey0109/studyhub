import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/repositories/post_repository.dart';

abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchQueryEvent extends SearchEvent {
  final String query, userId;
  SearchQueryEvent({required this.query, required this.userId});
  @override
  List<Object?> get props => [query, userId];
}

class ClearSearchEvent extends SearchEvent {}

abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<UserEntity> users;
  final List<PostEntity> posts;
  final String query;
  SearchLoaded({required this.users, required this.posts, required this.query});
  @override
  List<Object?> get props => [users, posts, query];
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final PostRepository repository;
  SearchBloc({required this.repository}) : super(SearchInitial()) {
    on<SearchQueryEvent>(_onSearch);
    on<ClearSearchEvent>((_, emit) => emit(SearchInitial()));
  }

  Future<void> _onSearch(
      SearchQueryEvent event, Emitter<SearchState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }
    emit(SearchLoading());
    try {
      final result = await repository.search(event.query.trim(), event.userId);
      emit(SearchLoaded(
        users: List<UserEntity>.from(result['users'] ?? []),
        posts: List<PostEntity>.from(result['posts'] ?? []),
        query: event.query,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
