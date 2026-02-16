import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:notchnco_task/core/network/network_info.dart';
import 'package:notchnco_task/data/datasources/movie_local_data_source.dart';
import 'package:notchnco_task/data/datasources/movie_remote_data_source.dart';
import 'package:notchnco_task/data/repositories/movie_repository_impl.dart';
import 'package:notchnco_task/domain/repositories/movie_repository.dart';
import 'package:notchnco_task/domain/usecases/favorites_usecases.dart';
import 'package:notchnco_task/domain/usecases/get_movie_details.dart';
import 'package:notchnco_task/domain/usecases/get_popular_movies.dart';
import 'package:notchnco_task/domain/usecases/get_movie_collection.dart';
import 'package:notchnco_task/domain/usecases/get_movies_by_genre.dart';
import 'package:notchnco_task/domain/usecases/get_genres.dart';
import 'package:notchnco_task/presentation/cubit/collections/collections_cubit.dart';
import 'package:notchnco_task/presentation/cubit/genres/genres_cubit.dart';
import 'package:notchnco_task/presentation/cubit/genre_movies/genre_movies_cubit.dart';
import 'package:notchnco_task/presentation/cubit/favorites/favorites_cubit.dart';
import 'package:notchnco_task/presentation/cubit/movie_details/movie_details_cubit.dart';
import 'package:notchnco_task/presentation/cubit/popular_movies/popular_movies_cubit.dart';

final sl = GetIt.instance; // Singleton

Future<void> initializeDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(sl<Connectivity>()),
  );
  
  sl.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  
  sl.registerLazySingleton<MovieLocalDataSource>(
    () => MovieLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );
  
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(
      remoteDataSource: sl<MovieRemoteDataSource>(),
      localDataSource: sl<MovieLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  
  sl.registerLazySingleton(() => GetPopularMovies(sl<MovieRepository>()));
  sl.registerLazySingleton(() => GetMovieDetails(sl<MovieRepository>()));
  sl.registerLazySingleton(() => ToggleFavorite(sl<MovieRepository>()));
  sl.registerLazySingleton(() => GetFavorites(sl<MovieRepository>()));
  sl.registerLazySingleton(() => IsFavorite(sl<MovieRepository>()));
  sl.registerLazySingleton(() => GetMovieCollection(sl<MovieRepository>()));
  sl.registerLazySingleton(() => GetGenres(sl<MovieRepository>()));
  sl.registerLazySingleton(() => GetMoviesByGenre(sl<MovieRepository>()));
  
  sl.registerFactory(
    () => PopularMoviesCubit(
      getPopularMovies: sl<GetPopularMovies>(),
      getGenres: sl<GetGenres>(),
      toggleFavorite: sl<ToggleFavorite>(),
      isFavorite: sl<IsFavorite>(),
    ),
  );
  
  sl.registerFactory(
    () => MovieDetailsCubit(
      getMovieDetails: sl<GetMovieDetails>(),
      toggleFavorite: sl<ToggleFavorite>(),
      isFavorite: sl<IsFavorite>(),
    ),
  );
  
  sl.registerFactory(
    () => FavoritesCubit(
      getFavorites: sl<GetFavorites>(),
      toggleFavorite: sl<ToggleFavorite>(),
    ),
  );

  sl.registerFactory(
    () => CollectionsCubit(
      getMovieCollection: sl<GetMovieCollection>(),
    ),
  );

  sl.registerFactory(
    () => GenresCubit(
      getGenres: sl<GetGenres>(),
    ),
  );

  sl.registerFactory(
    () => GenreMoviesCubit(
      getMoviesByGenre: sl<GetMoviesByGenre>(),
      toggleFavorite: sl<ToggleFavorite>(),
      isFavorite: sl<IsFavorite>(),
    ),
  );
}
