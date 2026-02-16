import 'package:dartz/dartz.dart';

import 'package:notchnco_task/core/errors/failures.dart';
import 'package:notchnco_task/domain/entities/movie.dart';
import 'package:notchnco_task/domain/entities/movie_details.dart';
import 'package:notchnco_task/domain/entities/genre.dart';
import 'package:notchnco_task/domain/entities/movie_collection.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> getPopularMovies(int page);
  
  Future<Either<Failure, List<Genre>>> getGenres();
  
  Future<Either<Failure, MovieDetails>> getMovieDetails(int movieId);
  
  Future<Either<Failure, void>> addFavorite(Movie movie);
  Future<Either<Failure, void>> removeFavorite(int movieId);
  Future<Either<Failure, List<Movie>>> getFavorites();
  Future<Either<Failure, bool>> isFavorite(int movieId);
  Future<Either<Failure, MovieCollection>> getCollection(int collectionId);
  Future<Either<Failure, List<Movie>>> getMoviesByGenre(int genreId, int page);
}
