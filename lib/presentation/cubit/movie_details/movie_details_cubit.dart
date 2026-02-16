import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notchnco_task/core/base_state/base_state.dart';
import 'package:notchnco_task/domain/entities/movie_details.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/usecases/favorites_usecases.dart';
import '../../../domain/usecases/get_movie_details.dart';

class MovieDetailsData extends Equatable {
  final MovieDetails movieDetails;
  final bool isFavorite;

  const MovieDetailsData({
    required this.movieDetails,
    required this.isFavorite,
  });

  MovieDetailsData copyWith({
    MovieDetails? movieDetails,
    bool? isFavorite,
  }) {
    return MovieDetailsData(
      movieDetails: movieDetails ?? this.movieDetails,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [movieDetails, isFavorite];
}

class MovieDetailsCubit extends Cubit<BaseState<MovieDetailsData>> {
  final GetMovieDetails getMovieDetails;
  final ToggleFavorite toggleFavorite;
  final IsFavorite isFavorite;
  
  MovieDetailsCubit({
    required this.getMovieDetails,
    required this.toggleFavorite,
    required this.isFavorite,
  }) : super(BaseInitial());
  
  Future<void> loadMovieDetails(int movieId) async {
    emit(BaseLoading());
    
    final detailsResult = await getMovieDetails(movieId);
    
    await detailsResult.fold(
      (failure) async {
        emit(BaseError(failure.message));
      },
      (details) async {
        final favoriteResult = await isFavorite(movieId);
        final isFav = favoriteResult.fold((_) => false, (status) => status);
        
        emit(BaseSuccess(MovieDetailsData(
          movieDetails: details,
          isFavorite: isFav,
        )));
      },
    );
  }
  
  Future<void> toggleMovieFavorite() async {
    final currentState = state;
    if (currentState is! BaseSuccess<MovieDetailsData>) return;
    
    final data = currentState.data;
    final movieDetails = data.movieDetails;
    final currentStatus = data.isFavorite;
    
    emit(BaseSuccess(data.copyWith(isFavorite: !currentStatus)));
    
    final movie = Movie(
      id: movieDetails.id,
      title: movieDetails.title,
      posterPath: movieDetails.posterPath,
      backdropPath: movieDetails.backdropPath,
      overview: movieDetails.overview,
      voteAverage: movieDetails.voteAverage,
      releaseDate: movieDetails.releaseDate,
      genreIds: movieDetails.genres.map((g) => g.id).toList(),
    );
    
    final result = await toggleFavorite(
      movie: movie,
      currentStatus: currentStatus,
    );
    
    result.fold(
      (failure) {
        emit(BaseSuccess(data.copyWith(isFavorite: currentStatus)));
      },
      (_) {
      },
    );
  }
  
  Future<void> retry(int movieId) async {
    await loadMovieDetails(movieId);
  }
}

