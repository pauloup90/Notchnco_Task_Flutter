import 'package:dartz/dartz.dart';
import 'package:notchnco_task/core/errors/failures.dart';
import 'package:notchnco_task/domain/entities/movie_collection.dart';
import 'package:notchnco_task/domain/repositories/movie_repository.dart';

class GetMovieCollection {
  final MovieRepository repository;

  GetMovieCollection(this.repository);

  Future<Either<Failure, MovieCollection>> call(int collectionId) async {
    return await repository.getCollection(collectionId);
  }
}
