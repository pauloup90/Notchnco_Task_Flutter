import 'package:flutter/material.dart';

import '../presentation/screens/favorites/favorites_screen.dart';
import '../presentation/screens/movie_details/movie_details_screen.dart';
import '../presentation/screens/popular_movies/popular_movies_screen.dart';
import '../presentation/screens/collections/collections_screen.dart';
import '../presentation/screens/genres/genres_screen.dart';
import '../presentation/screens/genre_movies/genre_movies_screen.dart';
import '../domain/entities/genre.dart';

class AppRoutes {
  static const String popularMovies = '/';
  static const String movieDetails = '/movie-details';
  static const String favorites = '/favorites';
  static const String collections = '/collections';
  static const String genres = '/genres';
  static const String genreMovies = '/genre-movies';
  
  static const String initial = genres;
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case popularMovies:
        return MaterialPageRoute(
          builder: (_) => const PopularMoviesScreen(),
        );
      
      case movieDetails:
        final movieId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => MovieDetailsScreen(movieId: movieId),
        );
      
      case favorites:
        return MaterialPageRoute(
          builder: (_) => const FavoritesScreen(),
        );

      case collections:
        return MaterialPageRoute(
          builder: (_) => const CollectionsScreen(),
        );

      case genres:
        return MaterialPageRoute(
          builder: (_) => const GenresScreen(),
        );

      case genreMovies:
        final genre = settings.arguments as Genre;
        return MaterialPageRoute(
          builder: (_) => GenreMoviesScreen(genre: genre),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

