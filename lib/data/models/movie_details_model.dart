import 'package:json_annotation/json_annotation.dart';
import 'package:notchnco_task/domain/entities/movie_details.dart';
import 'package:notchnco_task/data/models/genre_model.dart';

part 'movie_details_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MovieDetailsModel extends MovieDetails {
  @override
  final List<GenreModel> genres;

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
  @JsonKey(name: 'vote_count')
  final int? voteCount;

  const MovieDetailsModel({
    required super.id,
    required super.title,
    this.posterPath,
    this.backdropPath,
    required super.overview,
    required this.voteAverage,
    required this.releaseDate,
    required this.genres,
    super.runtime,
    super.tagline,
    super.popularity,
    this.voteCount,
  }) : super(
          genres: genres,
          posterPath: posterPath,
          backdropPath: backdropPath,
          voteAverage: voteAverage,
          releaseDate: releaseDate,
          voteCount: voteCount,
        );
  
  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$MovieDetailsModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$MovieDetailsModelToJson(this);

  
  factory MovieDetailsModel.fromEntity(MovieDetails details) {
    return MovieDetailsModel(
      id: details.id,
      title: details.title,
      posterPath: details.posterPath,
      backdropPath: details.backdropPath,
      overview: details.overview,
      voteAverage: details.voteAverage,
      releaseDate: details.releaseDate,
      genres: details.genres.map((g) => GenreModel.fromEntity(g)).toList(),
      runtime: details.runtime,
      tagline: details.tagline,
      popularity: details.popularity,
      voteCount: details.voteCount,
    );
  }
}



