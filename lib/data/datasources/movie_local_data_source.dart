import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/exceptions.dart';
import '../../core/utils/constants.dart';
import '../models/movie_model.dart';
import '../models/movie_details_model.dart';

abstract class MovieLocalDataSource {
  Future<void> addFavorite(MovieModel movie);
  Future<void> removeFavorite(int movieId);
  Future<List<MovieModel>> getFavorites();
  Future<bool> isFavorite(int movieId);
  
  Future<void> cacheMovies(String key, List<MovieModel> movies);
  Future<List<MovieModel>> getCachedMovies(String key);
  
  Future<void> cacheMovieDetails(MovieDetailsModel details);
  Future<MovieDetailsModel?> getCachedMovieDetails(int movieId);
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  final SharedPreferences sharedPreferences;
  List<MovieModel>? _favoritesCache; // In-memory cache
  
  MovieLocalDataSourceImpl({required this.sharedPreferences});
  
  static const String _favoritesKey = AppConstants.favoritesKey;
  static String _moviesCacheKey(String key) => '${AppConstants.cachedMoviesKey}$key';
  static String _movieDetailsKey(int id) => 'movie_details_$id';
  static String _cacheTimestampKey(String key) => '${key}_timestamp';
  
  @override
  Future<void> addFavorite(MovieModel movie) async {
    try {
      final favorites = await getFavorites();
      
      if (!favorites.any((m) => m.id == movie.id)) {
        favorites.add(movie);
        _updateFavoritesCache(favorites);
      }
    } catch (e) {
      throw CacheException('Failed to add favorite: $e');
    }
  }
  
  @override
  Future<void> removeFavorite(int movieId) async {
    try {
      final favorites = await getFavorites();
      favorites.removeWhere((m) => m.id == movieId);
      _updateFavoritesCache(favorites);
    } catch (e) {
      throw CacheException('Failed to remove favorite: $e');
    }
  }
  
  Future<void> _updateFavoritesCache(List<MovieModel> favorites) async {
    _favoritesCache = favorites;
    final jsonList = favorites.map((m) => m.toJson()).toList();
    await sharedPreferences.setString(_favoritesKey, jsonEncode(jsonList));
  }
  
  @override
  Future<List<MovieModel>> getFavorites() async {
    if (_favoritesCache != null) return _favoritesCache!;

    try {
      final jsonString = sharedPreferences.getString(_favoritesKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        _favoritesCache = [];
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      _favoritesCache = jsonList
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return _favoritesCache!;
    } catch (e) {
      throw CacheException('Failed to get favorites: $e');
    }
  }
  
  @override
  Future<bool> isFavorite(int movieId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((m) => m.id == movieId);
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<void> cacheMovies(String key, List<MovieModel> movies) async {
    try {
      final cacheKey = _moviesCacheKey(key);
      final jsonList = movies.map((m) => m.toJson()).toList();
      
      await sharedPreferences.setString(cacheKey, jsonEncode(jsonList));
      await sharedPreferences.setInt(
        _cacheTimestampKey(cacheKey),
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException('Failed to cache movies: $e');
    }
  }
  
  @override
  Future<List<MovieModel>> getCachedMovies(String key) async {
    try {
      final cacheKey = _moviesCacheKey(key);
      
      final timestamp = sharedPreferences.getInt(_cacheTimestampKey(cacheKey));
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        
        if (now.difference(cacheTime) > AppConstants.cacheExpiry) {
          return [];
        }
      }
      
      final jsonString = sharedPreferences.getString(cacheKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cached movies: $e');
    }
  }
  
  @override
  Future<void> cacheMovieDetails(MovieDetailsModel details) async {
    try {
      final key = _movieDetailsKey(details.id);
      await sharedPreferences.setString(key, jsonEncode(details.toJson()));
      await sharedPreferences.setInt(
        _cacheTimestampKey(key),
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException('Failed to cache movie details: $e');
    }
  }
  
  @override
  Future<MovieDetailsModel?> getCachedMovieDetails(int movieId) async {
    try {
      final key = _movieDetailsKey(movieId);
      
      final timestamp = sharedPreferences.getInt(_cacheTimestampKey(key));
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        
        if (now.difference(cacheTime) > AppConstants.cacheExpiry) {
          return null;
        }
      }
      
      final jsonString = sharedPreferences.getString(key);
      
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return MovieDetailsModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }
}
