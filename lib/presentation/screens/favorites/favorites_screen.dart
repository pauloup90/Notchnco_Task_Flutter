import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sizer/sizer.dart';

import 'package:notchnco_task/core/di/injection_container.dart';
import 'package:notchnco_task/core/base_state/base_state.dart';
import 'package:notchnco_task/domain/entities/movie.dart';
import 'package:notchnco_task/presentation/cubit/favorites/favorites_cubit.dart';
import 'package:notchnco_task/routes/app_routes.dart';
import 'package:notchnco_task/widgets/custom_bottom_bar.dart';
import 'package:notchnco_task/presentation/widgets/movie_card_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FavoritesCubit>(
      create: (_) => sl<FavoritesCubit>()..loadFavorites(),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'My Favorites',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      body: BlocBuilder<FavoritesCubit, BaseState<List<Movie>>>(
        builder: (context, state) {
          if (state is BaseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BaseError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                  SizedBox(height: 2.h),
                  Text(
                    (state as BaseError).message,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else if (state is BaseSuccess<List<Movie>>) {
            final favorites = state.data;
            if (favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 2.h),
                    Text(
                      'No favorites yet',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Start adding movies to your favorites!',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return AnimationLimiter(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final movie = favorites[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: MovieCardWidget(
                          movie: movie,
                          isFavorite: true,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.movieDetails,
                              arguments: movie.id,
                            ).then((_) {
                              context.read<FavoritesCubit>().loadFavorites();
                            });
                          },
                          onFavoriteToggle: () {
                            context.read<FavoritesCubit>().removeFavorite(movie);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.genres);
          }
        },
      ),
    );
  }
}
