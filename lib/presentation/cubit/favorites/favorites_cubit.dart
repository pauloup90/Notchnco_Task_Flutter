import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notchnco_task/core/base_state/base_state.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/usecases/favorites_usecases.dart';

class FavoritesCubit extends Cubit<BaseState<List<Movie>>> {
  final GetFavorites getFavorites;
  final ToggleFavorite toggleFavorite;
  
  FavoritesCubit({
    required this.getFavorites,
    required this.toggleFavorite,
  }) : super(BaseInitial());
  
  Future<void> loadFavorites() async {
    emit(BaseLoading());
    
    final result = await getFavorites();
    
    result.fold(
      (failure) => emit(BaseError(failure.message)),
      (favorites) => emit(BaseSuccess(favorites)),
    );
  }
  
  Future<void> removeFavorite(Movie movie) async {
    final currentState = state;
    if (currentState is! BaseSuccess<List<Movie>>) return;
    
    final updatedFavorites = currentState.data
        .where((m) => m.id != movie.id)
        .toList();
    
    emit(BaseSuccess(updatedFavorites));
    
    final result = await toggleFavorite(
      movie: movie,
      currentStatus: true, // Currently favorite, so remove
    );
    
    result.fold(
      (failure) {
        final revertedFavorites = [...updatedFavorites, movie];
        emit(BaseSuccess(revertedFavorites));
      },
      (_) {
      },
    );
  }
  
  Future<void> refreshFavorites() async {
    await loadFavorites();
  }
}

