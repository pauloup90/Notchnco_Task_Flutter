import 'package:equatable/equatable.dart';
import 'package:notchnco_task/domain/entities/genre.dart';

class MovieDetails extends Equatable {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;
  final List<Genre> genres;
  final int? runtime;
  final String? tagline;
  final double? popularity;
  final int? voteCount;
  
  const MovieDetails({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
    required this.genres,
    this.runtime,
    this.tagline,
    this.popularity,
    this.voteCount,
  });
  
  String get releaseYear {
    if (releaseDate.isEmpty) return 'N/A';
    try {
      return releaseDate.split('-').first;
    } catch (e) {
      return 'N/A';
    }
  }
  
  String get formattedRating {
    if (voteAverage == 0) return '—';
    return voteAverage.toStringAsFixed(1);
  }
  
  String get formattedRuntime {
    if (runtime == null || runtime == 0) return 'N/A';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
  
  String get genreNames {
    if (genres.isEmpty) return 'N/A';
    return genres.map((g) => g.name).join(', ');
  }
  
  bool get hasPoster => posterPath != null && posterPath!.isNotEmpty;
  bool get hasBackdrop => backdropPath != null && backdropPath!.isNotEmpty;
  bool get hasOverview => overview.isNotEmpty;
  bool get hasTagline => tagline != null && tagline!.isNotEmpty;
  
  @override
  List<Object?> get props => [
        id,
        title,
        posterPath,
        backdropPath,
        overview,
        voteAverage,
        releaseDate,
        genres,
        runtime,
        tagline,
        popularity,
        voteCount,
      ];
}
