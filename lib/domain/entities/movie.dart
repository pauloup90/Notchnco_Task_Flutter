import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds;
  
  const Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
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
    return voteAverage.toStringAsFixed(1);
  }
  
  bool get hasPoster => posterPath != null && posterPath!.isNotEmpty;
  
  bool get hasOverview => overview.isNotEmpty;
  
  @override
  List<Object?> get props => [
        id,
        title,
        posterPath,
        backdropPath,
        overview,
        voteAverage,
        releaseDate,
        genreIds,
      ];
}
