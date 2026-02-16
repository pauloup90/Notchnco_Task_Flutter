import 'package:dartz/dartz.dart';
import 'package:notchnco_task/core/errors/failures.dart';
import 'package:notchnco_task/domain/entities/genre.dart';
import 'package:notchnco_task/domain/repositories/movie_repository.dart';

class GetGenres {
  final MovieRepository repository;

  GetGenres(this.repository);

  Future<Either<Failure, List<Genre>>> call() async {
    return await repository.getGenres();
  }
}
