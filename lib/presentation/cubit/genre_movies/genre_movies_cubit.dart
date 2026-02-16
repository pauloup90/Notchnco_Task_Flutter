import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notchnco_task/core/base_state/base_state.dart';
import 'package:notchnco_task/domain/entities/movie.dart';
import 'package:notchnco_task/domain/usecases/favorites_usecases.dart';
import 'package:notchnco_task/domain/usecases/get_movies_by_genre.dart';

class GenreMoviesData extends Equatable {
  final List<Movie> movies;
  final int currentPage;
  final bool hasMore;
  final Map<int, bool> favoriteStatus;

  const GenreMoviesData({
    required this.movies,
    required this.currentPage,
    required this.hasMore,
    required this.favoriteStatus,
  });

  GenreMoviesData copyWith({
    List<Movie>? movies,
    int? currentPage,
    bool? hasMore,
    Map<int, bool>? favoriteStatus,
  }) {
    return GenreMoviesData(
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
    );
  }

  @override
  List<Object?> get props => [movies, currentPage, hasMore, favoriteStatus];
}

class GenreMoviesCubit extends Cubit<BaseState<GenreMoviesData>> {
  final GetMoviesByGenre getMoviesByGenre;
  final ToggleFavorite toggleFavorite;
  final IsFavorite isFavorite;

  GenreMoviesCubit({
    required this.getMoviesByGenre,
    required this.toggleFavorite,
    required this.isFavorite,
  }) : super(BaseInitial());

  Future<void> loadMoviesByGenre(int genreId) async {
    emit(BaseLoading());

    final result = await getMoviesByGenre(genreId, 1);

    result.fold(
      (failure) => emit(BaseError(failure.message)),
      (movies) async {
        final favoriteStatus = await _loadFavoriteStatuses(movies);
        emit(BaseSuccess(GenreMoviesData(
          movies: movies,
          currentPage: 1,
          hasMore: movies.length == 20,
          favoriteStatus: favoriteStatus,
        )));
      },
    );
  }

  Future<void> loadMoreMovies(int genreId) async {
    final currentState = state;
    if (currentState is! BaseSuccess<GenreMoviesData> || !currentState.data.hasMore) return;

    final data = currentState.data;
    final nextPage = data.currentPage + 1;
    final result = await getMoviesByGenre(genreId, nextPage);

    result.fold(
      (failure) => {}, // Handle silently or with snackbar
      (newMovies) async {
        final allMovies = [...data.movies, ...newMovies];
        final newFavoriteStatus = await _loadFavoriteStatuses(newMovies);
        
        emit(BaseSuccess(data.copyWith(
          movies: allMovies,
          currentPage: nextPage,
          hasMore: newMovies.length == 20,
          favoriteStatus: {...data.favoriteStatus, ...newFavoriteStatus},
        )));
      },
    );
  }

  Future<void> toggleMovieFavorite(Movie movie) async {
    final currentState = state;
    if (currentState is! BaseSuccess<GenreMoviesData>) return;

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

