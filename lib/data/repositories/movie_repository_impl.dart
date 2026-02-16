import 'package:dartz/dartz.dart';

import 'package:notchnco_task/core/errors/exceptions.dart';
import 'package:notchnco_task/core/errors/failures.dart';
import 'package:notchnco_task/core/network/network_info.dart';
import 'package:notchnco_task/domain/entities/movie.dart';
import 'package:notchnco_task/domain/entities/genre.dart';
import 'package:notchnco_task/domain/entities/movie_collection.dart';
import 'package:notchnco_task/domain/entities/movie_details.dart';
import 'package:notchnco_task/domain/repositories/movie_repository.dart';
import 'package:notchnco_task/data/datasources/movie_local_data_source.dart';
import 'package:notchnco_task/data/datasources/movie_remote_data_source.dart';
import 'package:notchnco_task/data/models/movie_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies(int page) async {
    final isConnected = await networkInfo.isConnected;
    
    if (!isConnected) {
      try {
        final cachedMovies = await localDataSource.getCachedMovies('popular_page_$page');
        if (cachedMovies.isNotEmpty) {
          return Right(cachedMovies);
        }
        return const Left(NetworkFailure('No internet connection and no cached data'));
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
    
    try {
      final movies = await remoteDataSource.getPopularMovies(page);
      
      try {
        await localDataSource.cacheMovies('popular_page_$page', movies);
      } catch (_) {
      }
      
      return Right(movies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }
  
  @override
  Future<Either<Failure, List<Genre>>> getGenres() async {
    if (await networkInfo.isConnected) {
      try {
        final genres = await remoteDataSource.getGenres();
        return Right(genres);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(UnexpectedFailure('Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, MovieDetails>> getMovieDetails(int movieId) async {
    try {
      final cachedDetails = await localDataSource.getCachedMovieDetails(movieId);
      if (cachedDetails != null) {
        final isConnected = await networkInfo.isConnected;
        if (isConnected) {
          _updateMovieDetailsCache(movieId);
        }
        return Right(cachedDetails);
      }
    } catch (_) {
    }
    
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    
    try {
      final details = await remoteDataSource.getMovieDetails(movieId);
      
      try {
        await localDataSource.cacheMovieDetails(details);
      } catch (_) {
      }
      
      return Right(details);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: $e'));
    }
  }
  
  Future<void> _updateMovieDetailsCache(int movieId) async {
    try {
      final details = await remoteDataSource.getMovieDetails(movieId);
      await localDataSource.cacheMovieDetails(details);
    } catch (_) {
    }
  }
  
  @override
  Future<Either<Failure, void>> addFavorite(Movie movie) async {
    try {
      final movieModel = MovieModel.fromEntity(movie);
      await localDataSource.addFavorite(movieModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to add favorite: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> removeFavorite(int movieId) async {
    try {
      await localDataSource.removeFavorite(movieId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to remove favorite: $e'));
    }
  }
  
  @override
  Future<Either<Failure, List<Movie>>> getFavorites() async {
    try {
      final favorites = await localDataSource.getFavorites();
      return Right(favorites);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get favorites: $e'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> isFavorite(int movieId) async {
    try {
      final result = await localDataSource.isFavorite(movieId);
      return Right(result);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, MovieCollection>> getCollection(int collectionId) async {
    if (await networkInfo.isConnected) {
      try {
        final collection = await remoteDataSource.getCollection(collectionId);
        return Right(collection);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnexpectedFailure('Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getMoviesByGenre(int genreId, int page) async {
    if (await networkInfo.isConnected) {
      try {
        final movies = await remoteDataSource.getMoviesByGenre(genreId, page);
        return Right(movies);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnexpectedFailure('Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
