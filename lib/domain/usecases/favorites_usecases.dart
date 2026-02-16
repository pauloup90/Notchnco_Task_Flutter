import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class ToggleFavorite {
  final MovieRepository repository;
  
  ToggleFavorite(this.repository);
  
  Future<Either<Failure, bool>> call({
    required Movie movie,
    required bool currentStatus,
  }) async {
    if (currentStatus) {
      final result = await repository.removeFavorite(movie.id);
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(false),
      );
    } else {
      final result = await repository.addFavorite(movie);
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(true),
      );
    }
  }
}

class GetFavorites {
  final MovieRepository repository;
  
  GetFavorites(this.repository);
  
  Future<Either<Failure, List<Movie>>> call() async {
    return await repository.getFavorites();
  }
}

class IsFavorite {
  final MovieRepository repository;
  
  IsFavorite(this.repository);
  
  Future<Either<Failure, bool>> call(int movieId) async {
    return await repository.isFavorite(movieId);
  }
}
