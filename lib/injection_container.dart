import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'data/datasources/local/hive_local_datasource.dart';
import 'data/datasources/remote/supabase_remote_datasource.dart';
import 'data/datasources/remote/wordpress_remote_datasource.dart';

import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/post_repository_impl.dart';
import 'data/repositories/friend_repository_impl.dart';
import 'data/repositories/story_repository_impl.dart';

import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/post_repository.dart';
import 'domain/repositories/friend_repository.dart';
import 'domain/repositories/story_repository.dart';

import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';

import 'domain/usecases/friend/send_friend_request_usecase.dart';
import 'domain/usecases/friend/accept_friend_request_usecase.dart';
import 'domain/usecases/friend/get_friend_requests_usecase.dart';
import 'domain/usecases/friend/get_friends_usecase.dart';
import 'domain/usecases/friend/get_suggestions_usecase.dart';

import 'domain/usecases/story/get_stories_usecase.dart';
import 'domain/usecases/story/create_story_usecase.dart';
import 'domain/usecases/story/react_to_story_usecase.dart';
import 'domain/usecases/story/delete_story_usecase.dart';

import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/post/post_bloc.dart';
import 'presentation/blocs/friend/friend_bloc.dart';
import 'presentation/blocs/notification/notification_bloc.dart';
import 'presentation/blocs/search/search_bloc.dart';
import 'presentation/blocs/chat/chat_bloc.dart';
import 'presentation/blocs/story/story_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /// DATASOURCES
  sl.registerLazySingleton<HiveLocalDatasource>(
    () => HiveLocalDatasource(),
  );

  sl.registerLazySingleton<SupabaseRemoteDatasource>(
    () => SupabaseRemoteDatasource(),
  );

  /// WORDPRESS API
  sl.registerLazySingleton<Dio>(() => Dio());

  sl.registerLazySingleton<PostRemoteDataSource>(
    () => WordPressRemoteDataSourceImpl(
      dio: sl(),
    ),
  );

  /// REPOSITORIES
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: sl(),
      local: sl(),
    ),
  );

  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remote: sl(),
      local: sl(),
    ),
  );

  sl.registerLazySingleton<FriendRepository>(
    () => FriendRepositoryImpl(
      remote: sl(),
      local: sl(),
    ),
  );

  sl.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(
      remote: sl(),
      local: sl(),
    ),
  );

  /// AUTH USECASES
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  /// FRIEND USECASES
  sl.registerLazySingleton(() => SendFriendRequestUseCase(sl()));
  sl.registerLazySingleton(() => AcceptFriendRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetFriendRequestsUseCase(sl()));
  sl.registerLazySingleton(() => GetFriendsUseCase(sl()));
  sl.registerLazySingleton(() => GetSuggestionsUseCase(sl()));

  /// STORY USECASES
  sl.registerLazySingleton(() => GetStoriesUseCase(sl()));
  sl.registerLazySingleton(() => CreateStoryUseCase(sl()));
  sl.registerLazySingleton(() => ReactToStoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteStoryUseCase(sl()));

  /// BLOCS
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      local: sl(),
    ),
  );

  sl.registerFactory<PostBloc>(
    () => PostBloc(repository: sl()),
  );

  sl.registerFactory<FriendBloc>(
    () => FriendBloc(
      sendRequestUseCase: sl(),
      acceptRequestUseCase: sl(),
      getFriendRequestsUseCase: sl(),
      getFriendsUseCase: sl(),
      getSuggestionsUseCase: sl(),
      localDatasource: sl(),
    ),
  );

  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      remoteDatasource: sl(),
      localDatasource: sl(),
    ),
  );

  sl.registerFactory<SearchBloc>(
    () => SearchBloc(repository: sl()),
  );

  sl.registerFactory<ChatBloc>(
    () => ChatBloc(
      remoteDatasource: sl(),
      localDatasource: sl(),
    ),
  );

  sl.registerFactory<StoryBloc>(
    () => StoryBloc(
      getStoriesUseCase: sl(),
      createStoryUseCase: sl(),
      reactToStoryUseCase: sl(),
      deleteStoryUseCase: sl(),
    ),
  );
}
