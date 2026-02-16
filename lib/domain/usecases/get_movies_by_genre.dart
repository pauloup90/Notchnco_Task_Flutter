import 'package:dartz/dartz.dart';
import 'package:notchnco_task/core/errors/failures.dart';
import 'package:notchnco_task/domain/entities/movie.dart';
import 'package:notchnco_task/domain/repositories/movie_repository.dart';

class GetMoviesByGenre {
  final MovieRepository repository;

  GetMoviesByGenre(this.repository);

  Future<Either<Failure, List<Movie>>> call(int genreId, int page) async {
    return await repository.getMoviesByGenre(genreId, page);
  }
}
