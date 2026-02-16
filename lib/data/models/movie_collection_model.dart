import 'package:json_annotation/json_annotation.dart';
import 'package:notchnco_task/data/models/movie_model.dart';
import 'package:notchnco_task/domain/entities/movie_collection.dart';

part 'movie_collection_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MovieCollectionModel extends MovieCollection {
  @override
  @JsonKey(name: 'parts')
  final List<MovieModel> movies;

  @override
  @JsonKey(name: 'poster_path')
  final String? posterPath;

  @override
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;

  const MovieCollectionModel({
    required super.id,
    required super.name,
    required super.overview,
    this.posterPath,
    this.backdropPath,
    required this.movies,
  }) : super(
          movies: movies,
          posterPath: posterPath,
          backdropPath: backdropPath,
        );

  factory MovieCollectionModel.fromJson(Map<String, dynamic> json) =>
      _$MovieCollectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieCollectionModelToJson(this);
}

