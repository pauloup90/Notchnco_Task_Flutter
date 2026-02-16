// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_collection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieCollectionModel _$MovieCollectionModelFromJson(
  Map<String, dynamic> json,
) => MovieCollectionModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  overview: json['overview'] as String,
  posterPath: json['poster_path'] as String?,
  backdropPath: json['backdrop_path'] as String?,
  movies: (json['parts'] as List<dynamic>)
      .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MovieCollectionModelToJson(
  MovieCollectionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'overview': instance.overview,
  'parts': instance.movies.map((e) => e.toJson()).toList(),
  'poster_path': instance.posterPath,
  'backdrop_path': instance.backdropPath,
};
