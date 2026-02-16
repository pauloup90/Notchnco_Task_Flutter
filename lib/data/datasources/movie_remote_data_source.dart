import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:notchnco_task/core/errors/exceptions.dart';
import 'package:notchnco_task/core/utils/constants.dart';
import 'package:notchnco_task/data/models/movie_model.dart';
import 'package:notchnco_task/data/models/movie_details_model.dart';
import 'package:notchnco_task/data/models/genre_model.dart';
import 'package:notchnco_task/data/models/movie_collection_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getPopularMovies(int page);
  Future<MovieDetailsModel> getMovieDetails(int movieId);
  Future<List<GenreModel>> getGenres();
  Future<MovieCollectionModel> getCollection(int collectionId);
  Future<List<MovieModel>> getMoviesByGenre(int genreId, int page);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final Dio dio;
  
  MovieRemoteDataSourceImpl({required this.dio}) {
    _configureDio();
  }
  
  void _configureDio() {
    final accessToken = dotenv.env['TMDB_ACCESS_TOKEN'] ?? '';
    
    if (accessToken.isEmpty) {
      throw const ServerException('TMDB access token not configured');
    }
    
    dio.options = BaseOptions(
      baseUrl: AppConstants.tmdbBaseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'accept': 'application/json',
      },
    );
    
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          handler.next(_handleDioError(error));
        },
      ),
    );
  }
  
  DioException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const NetworkException('Connection timeout');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['status_message'] ?? 'Server error';
        
        if (statusCode != null && statusCode >= 500) {
          throw ServerException('Server error ($statusCode): $message');
        } else if (statusCode == 401) {
          throw const ServerException('Unauthorized - Invalid API key');
        } else if (statusCode == 404) {
          throw const ServerException('Resource not found');
        } else {
          throw ServerException('Request failed ($statusCode): $message');
        }
      
      case DioExceptionType.cancel:
        throw const ServerException('Request cancelled');
      
      case DioExceptionType.unknown:
        if (error.error.toString().contains('SocketException')) {
          throw const NetworkException('No internet connection');
        }
        throw ServerException('Unexpected error: ${error.message}');
      
      default:
        throw ServerException('Network error: ${error.message}');
    }
  }
  
  @override
  Future<List<MovieModel>> getPopularMovies(int page) async {
    try {
      final response = await dio.get(
        '/movie/popular',
        queryParameters: {
          'language': 'en-US',
          'page': page,
        },
      );
      
      final results = response.data['results'] as List<dynamic>;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException('Failed to parse movies: $e');
    }
  }
  
  @override
  Future<MovieDetailsModel> getMovieDetails(int movieId) async {
    try {
      final response = await dio.get(
        '/movie/$movieId',
        queryParameters: {
          'language': 'en-US',
        },
      );
      
      return MovieDetailsModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException('Failed to parse movie details: $e');
    }
  }

  @override
  Future<List<GenreModel>> getGenres() async {
    try {
      final response = await dio.get(
        '/genre/movie/list',
        queryParameters: {
          'language': 'en-US',
        },
      );

      final results = response.data['genres'] as List<dynamic>;
      return results
          .map((json) => GenreModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException('Failed to parse genres: $e');
    }
  }

  @override
  Future<MovieCollectionModel> getCollection(int collectionId) async {
    try {
      final response = await dio.get(
        '/collection/$collectionId',
        queryParameters: {
          'language': 'en-US',
        },
      );

      return MovieCollectionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException('Failed to parse collection: $e');
    }
  }

  @override
  Future<List<MovieModel>> getMoviesByGenre(int genreId, int page) async {
    try {
      final response = await dio.get(
        '/discover/movie',
        queryParameters: {
          'with_genres': genreId,
          'page': page,
          'language': 'en-US',
          'sort_by': 'popularity.desc',
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException('Failed to parse movies by genre: $e');
    }
  }
}
