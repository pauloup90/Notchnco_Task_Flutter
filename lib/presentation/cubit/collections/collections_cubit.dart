import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notchnco_task/core/base_state/base_state.dart';
import 'package:notchnco_task/domain/entities/movie_collection.dart';
import 'package:notchnco_task/domain/usecases/get_movie_collection.dart';

class CollectionsCubit extends Cubit<BaseState<List<MovieCollection>>> {
  final GetMovieCollection getMovieCollection;

  CollectionsCubit({required this.getMovieCollection}) : super(BaseInitial());

  static const List<int> _collectionIds = [
    10,
    1241,
    86311,
    119,
    328,
    263,
  ];

  Future<void> loadCollections() async {
    emit(BaseLoading());

    try {
      final List<MovieCollection> collections = [];
      
      for (final id in _collectionIds) {
        final result = await getMovieCollection(id);
        result.fold(
          (failure) {
            // Log error or handle it, but continue for other collections
          },
          (collection) {
            collections.add(collection);
          },
        );
      }

      if (collections.isEmpty) {
        emit(const BaseError('Failed to load any collections'));
      } else {
        emit(BaseSuccess(collections));
      }
    } catch (e) {
      emit(BaseError('Unexpected error: $e'));
    }
  }
}

