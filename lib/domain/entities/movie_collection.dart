import 'package:equatable/equatable.dart';
import 'movie.dart';

class MovieCollection extends Equatable {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final List<Movie> movies;

  const MovieCollection({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.movies,
  });

  @override
  List<Object?> get props => [id, name, overview, posterPath, backdropPath, movies];
}
