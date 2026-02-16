import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notchnco_task/core/base_state/base_state.dart';
import 'package:notchnco_task/domain/entities/genre.dart';
import 'package:notchnco_task/domain/usecases/get_genres.dart';

class GenresCubit extends Cubit<BaseState<List<Genre>>> {
  final GetGenres getGenres;

  GenresCubit({required this.getGenres}) : super(BaseInitial());

  Future<void> loadGenres() async {
    emit(BaseLoading());

    final result = await getGenres();

    result.fold(
      (failure) => emit(BaseError(failure.message)),
      (genres) => emit(BaseSuccess(genres)),
    );
  }
}

