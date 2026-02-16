import 'constants.dart';

class ImageHelper {
  static String getPosterUrl(String? posterPath, {String size = 'w500'}) {
    if (posterPath == null || posterPath.isEmpty) {
      return '';
    }
    
    return '${AppConstants.tmdbImageBaseUrl}/$size$posterPath';
  }
  
  static String getBackdropUrl(String? backdropPath, {String size = 'w780'}) {
    if (backdropPath == null || backdropPath.isEmpty) {
      return '';
    }
    
    return '${AppConstants.tmdbImageBaseUrl}/$size$backdropPath';
  }
  
  static String getSmallPosterUrl(String? posterPath) {
    return getPosterUrl(posterPath, size: AppConstants.posterSizeW342);
  }
  
  static String getMediumPosterUrl(String? posterPath) {
    return getPosterUrl(posterPath, size: AppConstants.posterSizeW500);
  }
  
  static String getOriginalPosterUrl(String? posterPath) {
    return getPosterUrl(posterPath, size: AppConstants.posterSizeOriginal);
  }
  
  static String getMediumBackdropUrl(String? backdropPath) {
    return getBackdropUrl(backdropPath, size: AppConstants.backdropSizeW780);
  }
  
  static String getOriginalBackdropUrl(String? backdropPath) {
    return getBackdropUrl(backdropPath, size: AppConstants.backdropSizeOriginal);
  }
}
