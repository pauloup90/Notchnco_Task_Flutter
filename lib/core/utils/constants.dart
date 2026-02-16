class AppConstants {
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';
  
  static const String posterSizeW342 = 'w342';
  static const String posterSizeW500 = 'w500';
  static const String posterSizeOriginal = 'original';
  static const String backdropSizeW780 = 'w780';
  static const String backdropSizeOriginal = 'original';
  
  static const int moviesPerPage = 20;
  static const double paginationThreshold = 0.8; // Load more when 80% scrolled
  
  static const String favoritesKey = 'user_favorites';
  static const String cachedMoviesKey = 'cached_movies_';
  static const Duration cacheExpiry = Duration(hours: 24);
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  static const int maxRetries = 3;
  static const Duration imageLoadFadeDuration = Duration(milliseconds: 300);
}
