import 'package:json_annotation/json_annotation.dart';
import 'package:notchnco_task/domain/entities/genre.dart';

part 'genre_model.g.dart';

@JsonSerializable()
class GenreModel extends Genre {
  const GenreModel({
    required super.id,
    required super.name,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) => _$GenreModelFromJson(json);

  Map<String, dynamic> toJson() => _$GenreModelToJson(this);

  factory GenreModel.fromEntity(Genre genre) {
    return GenreModel(
      id: genre.id,
      name: genre.name,
    );
  }

  Genre toEntity() {
    return Genre(
      id: id,
      name: name,
    );
  }
}

