import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sizer/sizer.dart';

import 'package:notchnco_task/core/di/injection_container.dart';
import 'package:notchnco_task/domain/entities/genre.dart';
import 'package:notchnco_task/core/base_state/base_state.dart';
import 'package:notchnco_task/presentation/cubit/popular_movies/popular_movies_cubit.dart';
import 'package:notchnco_task/routes/app_routes.dart';
import 'package:notchnco_task/widgets/custom_bottom_bar.dart';
import 'package:notchnco_task/presentation/widgets/movie_card_widget.dart';

class PopularMoviesScreen extends StatelessWidget {
  const PopularMoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PopularMoviesCubit>(
      create: (_) => sl<PopularMoviesCubit>()..loadPopularMovies(),
      child: const _PopularMoviesView(),
    );
  }
}

class _PopularMoviesView extends StatefulWidget {
  const _PopularMoviesView();

  @override
  State<_PopularMoviesView> createState() => _PopularMoviesViewState();
}

class _PopularMoviesViewState extends State<_PopularMoviesView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<PopularMoviesCubit>().loadMoreMovies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'MovieHub',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
            },
          ),
        ],
      ),
      body: BlocBuilder<PopularMoviesCubit, BaseState<PopularMoviesData>>(
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
                   Text((state as BaseError).message, style: theme.textTheme.titleMedium),
                   SizedBox(height: 2.h),
                   ElevatedButton(
                     onPressed: () => context.read<PopularMoviesCubit>().loadPopularMovies(),
                     child: const Text('Retry'),
                   ),
                ],
              ),
            );
          } else if (state is BaseSuccess<PopularMoviesData>) {
            final data = state.data;
            final movies = data.movies;
            
            return RefreshIndicator(
              onRefresh: () => context.read<PopularMoviesCubit>().refreshMovies(),
              child: AnimationLimiter(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                  itemCount: movies.length + 1 + (data.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildGenresList(data.genres, theme);
                    }
                    
                    final movieIndex = index - 1;
                    
                    if (movieIndex >= movies.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                
                    final movie = movies[movieIndex];
                    final isFavorite = data.favoriteStatus[movie.id] ?? false;
                
                    return AnimationConfiguration.staggeredList(
                      position: movieIndex,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: MovieCardWidget(
                            movie: movie,
                            isFavorite: isFavorite,
                            onTap: () {
                              Navigator.pushNamed(
                                context, 
                                AppRoutes.movieDetails,
                                arguments: movie.id,
                              );
                            },
                            onFavoriteToggle: () {
                              context.read<PopularMoviesCubit>().toggleMovieFavorite(movie);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0, // This screen is not in the bar, but let's default to index 0
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.genres);
          } else if (index == 1) {
             Navigator.pushReplacementNamed(context, AppRoutes.favorites);
          }
        },
      ),
    );
  }

  Widget _buildGenresList(List<Genre> genres, ThemeData theme) {
    if (genres.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: 2.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              genre.name,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaginationError(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          TextButton(
            onPressed: () => context.read<PopularMoviesCubit>().loadMoreMovies(),
            child: const Text('Retry Loading More'),
          ),
        ],
      ),
    );
  }
}
