import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/movie.dart';

part 'movie_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MovieModel extends Movie {
  @override
  @JsonKey(name: 'poster_path')
  final String? posterPath;

  @override
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;

  @override
  @JsonKey(name: 'vote_average')
  final double voteAverage;

  @override
  @JsonKey(name: 'release_date')
  final String releaseDate;

  @override
  @JsonKey(name: 'genre_ids')
  final List<int> genreIds;

  const MovieModel({
    required super.id,
    required super.title,
    this.posterPath,
    this.backdropPath,
    required super.overview,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
  }) : super(
          posterPath: posterPath,
          backdropPath: backdropPath,
          voteAverage: voteAverage,
          releaseDate: releaseDate,
          genreIds: genreIds,
        );
  
  factory MovieModel.fromJson(Map<String, dynamic> json) => _$MovieModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$MovieModelToJson(this);
  
  factory MovieModel.fromEntity(Movie movie) {
    return MovieModel(
      id: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      overview: movie.overview,
      voteAverage: movie.voteAverage,
      releaseDate: movie.releaseDate,
      genreIds: movie.genreIds,
    );
  }
  
  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      posterPath: posterPath,
      backdropPath: backdropPath,
      overview: overview,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
      genreIds: genreIds,
    );
  }
}

