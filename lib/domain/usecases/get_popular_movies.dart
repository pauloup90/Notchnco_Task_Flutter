import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetPopularMovies {
  final MovieRepository repository;
  
  GetPopularMovies(this.repository);
  
  Future<Either<Failure, List<Movie>>> call(int page) async {
    return await repository.getPopularMovies(page);
  }
}
