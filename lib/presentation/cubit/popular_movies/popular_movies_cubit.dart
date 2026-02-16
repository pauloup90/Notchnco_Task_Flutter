import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:notchnco_task/core/base_state/base_state.dart';
import 'package:notchnco_task/core/errors/failures.dart';
import 'package:notchnco_task/domain/entities/movie.dart';
import 'package:notchnco_task/domain/entities/genre.dart';
import 'package:notchnco_task/domain/usecases/favorites_usecases.dart';
import 'package:notchnco_task/domain/usecases/get_popular_movies.dart';
import 'package:notchnco_task/domain/usecases/get_genres.dart';

class PopularMoviesData extends Equatable {
  final List<Movie> movies;
  final List<Genre> genres;
  final int currentPage;
  final bool hasMore;
  final Map<int, bool> favoriteStatus;
  final bool isLoadingMore;

  const PopularMoviesData({
    required this.movies,
    required this.genres,
    required this.currentPage,
    required this.hasMore,
    required this.favoriteStatus,
    this.isLoadingMore = false,
  });

  PopularMoviesData copyWith({
    List<Movie>? movies,
    List<Genre>? genres,
    int? currentPage,
    bool? hasMore,
    Map<int, bool>? favoriteStatus,
    bool? isLoadingMore,
  }) {
    return PopularMoviesData(
      movies: movies ?? this.movies,
      genres: genres ?? this.genres,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [movies, genres, currentPage, hasMore, favoriteStatus, isLoadingMore];
}

class PopularMoviesCubit extends Cubit<BaseState<PopularMoviesData>> {
  final GetPopularMovies getPopularMovies;
  final GetGenres getGenres;
  final ToggleFavorite toggleFavorite;
  final IsFavorite isFavorite;
  
  PopularMoviesCubit({
    required this.getPopularMovies,
    required this.getGenres,
    required this.toggleFavorite,
    required this.isFavorite,
  }) : super(BaseInitial());
  
  Future<void> loadPopularMovies({bool silent = false}) async {
    if (!silent) emit(BaseLoading());
    
    final results = await Future.wait([
      getPopularMovies(1),
      getGenres(),
    ]);

    final moviesResult = results[0] as Either<Failure, List<Movie>>;
    final genresResult = results[1] as Either<Failure, List<Genre>>;
    
    moviesResult.fold(
      (failure) {
        if (!silent) {
           emit(BaseError(failure.message));
        }
      },
      (movies) async {
        final genres = genresResult.getOrElse(() => []);
        final favoriteStatus = await _loadFavoriteStatuses(movies);
        
        emit(BaseSuccess(PopularMoviesData(
          movies: movies,
          genres: genres,
          currentPage: 1,
          hasMore: movies.length == 20,
          favoriteStatus: favoriteStatus,
        )));
      },
    );
  }

  Future<void> loadMoreMovies() async {
    final currentState = state;
    if (currentState is! BaseSuccess<PopularMoviesData> || !currentState.data.hasMore || currentState.data.isLoadingMore) {
      return;
    }
    
    final data = currentState.data;
    final nextPage = data.currentPage + 1;
    
    emit(BaseSuccess(data.copyWith(isLoadingMore: true)));
    
    final result = await getPopularMovies(nextPage);
    
    result.fold(
      (failure) {
        emit(BaseSuccess(data.copyWith(isLoadingMore: false)));
      },
      (newMovies) async {
        final allMovies = [...data.movies];
        for (final movie in newMovies) {
          if (!allMovies.any((m) => m.id == movie.id)) {
            allMovies.add(movie);
          }
        }
        
        final newFavoriteStatus = await _loadFavoriteStatuses(newMovies);
        final updatedFavoriteStatus = {
          ...data.favoriteStatus,
          ...newFavoriteStatus,
        };
        
        emit(BaseSuccess(data.copyWith(
          movies: allMovies,
          currentPage: nextPage,
          hasMore: newMovies.length == 20,
          favoriteStatus: updatedFavoriteStatus,
          isLoadingMore: false,
        )));
      },
    );
  }
  
  Future<void> refreshMovies() async {
    await loadPopularMovies(silent: true);
  }
  
  Future<void> toggleMovieFavorite(Movie movie) async {
    final currentState = state;
    if (currentState is! BaseSuccess<PopularMoviesData>) return;
    
    final data = currentState.data;
    final currentStatus = data.favoriteStatus[movie.id] ?? false;
    
    final updatedFavoriteStatus = {
      ...data.favoriteStatus,
      movie.id: !currentStatus,
    };
    
    emit(BaseSuccess(data.copyWith(favoriteStatus: updatedFavoriteStatus)));
    
    final result = await toggleFavorite(
      movie: movie,
      currentStatus: currentStatus,
    );
    
    result.fold(
      (failure) {
        final revertedStatus = {
          ...data.favoriteStatus,
          movie.id: currentStatus,
        };
        emit(BaseSuccess(data.copyWith(favoriteStatus: revertedStatus)));
      },
      (_) {},
    );
  }
  
  Future<Map<int, bool>> _loadFavoriteStatuses(List<Movie> movies) async {
    final Map<int, bool> statuses = {};
    for (final movie in movies) {
      final result = await isFavorite(movie.id);
      result.fold(
        (_) => statuses[movie.id] = false,
        (isFav) => statuses[movie.id] = isFav,
      );
    }
    return statuses;
  }
}

